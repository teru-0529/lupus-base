-- シーケンス
DROP SEQUENCE IF EXISTS inventories.payment_no_seed;
CREATE SEQUENCE inventories.payment_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.ordering_no_seed;
CREATE SEQUENCE inventories.ordering_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.warehousing_no_seed;
CREATE SEQUENCE inventories.warehousing_no_seed START 1;


-- 支払:登録「前」処理
--  導出属性の算出(支払ID/変更凍結日時)
--  有効桁数調整(支払金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.payments_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出(支払ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.payment_id:='PM'||to_char(nextval('inventories.payment_no_seed'),'FM00000000');
  END IF;

  -- 導出属性の算出(変更凍結日時)
  IF (NEW.freeze_changed_timestamp IS NULL AND (NEW.payment_status = 'CONFIRMED' OR NEW.payment_status = 'COMPLETED')) THEN
    NEW.freeze_changed_timestamp:=current_timestamp;
  END IF;

  -- 有効桁数調整(支払金額)
  NEW.payment_amount = ROUND(NEW.payment_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.payments
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payments_pre_process();


-- 支払:チェック制約
--  属性相関チェック制約(締日付/支払期限日付)

-- Create Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS deposit_date_check;
ALTER TABLE inventories.payments ADD CONSTRAINT deposit_date_check CHECK (
  cut_off_date < deposit_date
);

-- 支払:チェック制約
--  属性相関チェック制約(締日付/金額確定日付)

-- Create Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.payments ADD CONSTRAINT amount_confirmed_date_check CHECK (
  cut_off_date < amount_confirmed_date
);

-- 支払:チェック制約
--  属性相関チェック制約(締日付/金額確定日付)

-- Create Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_date_check;
ALTER TABLE inventories.payments ADD CONSTRAINT payment_date_check CHECK (
  cut_off_date < payment_date AND amount_confirmed_date <= payment_date
);
