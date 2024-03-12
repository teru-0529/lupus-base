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


-- 月次買掛金サマリ:登録「前」処理
--  導出属性の算出(残高)
--  有効桁数調整(月初残高/購入金額/支払金額/その他金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_payables_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(月初残高/購入金額/支払金額/その他金額)
  NEW.init_balance = ROUND(NEW.init_balance, 2);
  NEW.purchase_amount = ROUND(NEW.purchase_amount, 2);
  NEW.payment_amount = ROUND(NEW.payment_amount, 2);
  NEW.other_amount = ROUND(NEW.other_amount, 2);
  -- 導出属性の算出(在庫数量)
  NEW.present_balance = NEW.init_balance + NEW.purchase_amount - NEW.payment_amount + NEW.other_amount;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_payables_pre_process();


-- 現在買掛金サマリ:登録「前」処理
--  有効桁数調整(残高)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.current_payables_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(残高)
  NEW.present_balance = ROUND(NEW.present_balance, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.current_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_payables_pre_process();


-- 買掛変動履歴:チェック制約
--  属性相関チェック制約(買掛変動種類/変動金額/支払ID)

-- Create Constraint
ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_payable_type_check;
ALTER TABLE inventories.payable_histories ADD CONSTRAINT payable_histories_payable_type_check CHECK (
  CASE
    -- 買掛変動種類が「仕入購入」の場合、変動金額が0より大きい値であること
    WHEN payable_type = 'PURCHASE' AND variable_amount <= 0.00 THEN FALSE
    -- 買掛変動種類が「仕入返品」「支払」の場合、変動金額が0より小さい値であること
    WHEN payable_type = 'ORDER_RETURN' AND variable_amount >= 0.00 THEN FALSE
    WHEN payable_type = 'PAYMENT' AND variable_amount >= 0.00 THEN FALSE
    -- 買掛変動種類が「仕入購入」「仕入返品」「その他」の場合、支払IDがnullではないこと
    WHEN payable_type = 'PURCHASE' AND payment_id IS NULL THEN FALSE
    WHEN payable_type = 'ORDER_RETURN' AND payment_id IS NULL THEN FALSE
    WHEN payable_type = 'OTHER' AND payment_id IS NULL THEN FALSE
    -- 買掛変動種類が「支払」の場合、支払IDがnullであること
    WHEN payable_type = 'PAYMENT' AND payment_id IS NOT NULL THEN FALSE
    ELSE TRUE
  END
);


-- 買掛変動履歴:登録「前」処理
--  有効桁数調整(変動金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.payable_histories_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.payable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payable_histories_pre_process();
