-- シーケンス
DROP SEQUENCE IF EXISTS inventories.billing_no_seed;
CREATE SEQUENCE inventories.billing_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.deposit_no_seed;
CREATE SEQUENCE inventories.deposit_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.receiving_no_seed;
CREATE SEQUENCE inventories.receiving_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.shipping_no_seed;
CREATE SEQUENCE inventories.shipping_no_seed START 1;

-- 入金充当
-- Create Function
CREATE OR REPLACE PROCEDURE inventories.apply_deposit(i_costomer_id text) AS $$
-- FIXME:
-- FIXME:
-- FIXME:
-- DECLARE
--   rec RECORD;
--   r_billing_id text;
BEGIN
  -- SELECT * INTO rec FROM inventories.bills
  --   WHERE  costomer_id = i_costomer_id AND cut_off_date = i_cut_off_date AND deposit_limit_date = i_deposit_limit_date
  --   FOR UPDATE;

  -- IF rec IS NULL THEN
  --   INSERT INTO inventories.bills VALUES (
  --     default,
  --     i_costomer_id,
  --     i_cut_off_date,
  --     i_deposit_limit_date,
  --     i_variable_amount,
  --     default,
  --     default,
  --     default,
  --     NULL,
  --     NULL,
  --     default,
  --     default,
  --     i_create_by,
  --     i_create_by
  --   ) RETURNING billing_id INTO r_billing_id;
  --   RETURN r_billing_id;

  -- ELSE
  --   UPDATE inventories.bills
  --   SET billing_amount = rec.billing_amount + i_variable_amount,
  --       updated_by = i_create_by
  --   WHERE  billing_id = rec.billing_id;
  --   RETURN rec.billing_id;
  -- END IF;

-- FIXME:
-- FIXME:
-- FIXME:
  RETURN;
END;
$$ LANGUAGE plpgsql;


-- 請求:登録「前」処理
--  導出属性の算出:登録時のみ(請求ID)
--  導出属性の算出(残額/変更凍結日時/請求状況)
--  有効桁数調整(請求金額/充当済金額)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.bills_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(請求ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.billing_id:='BL-'||to_char(nextval('inventories.billing_no_seed'),'FM0000000');
  END IF;

  -- 有効桁数調整(請求金額/充当済金額)
  NEW.billing_amount = ROUND(NEW.billing_amount, 2);
  NEW.applied_amount = ROUND(NEW.applied_amount, 2);

--  導出属性の算出(残額)
  NEW.remaining_amount = ROUND(NEW.billing_amount - NEW.applied_amount, 2);

  -- 導出属性の算出(変更凍結日時/請求状況)
  IF NEW.remaining_amount = 0 THEN
    NEW.billing_status = 'COMPLETED';

  ELSIF NEW.applied_amount > 0 THEN
    NEW.billing_status = 'PART_OF_DEPOSITED';

  ELSIF (OLD.amount_confirmed_date IS NULL AND NEW.amount_confirmed_date IS NOT NULL) THEN
    NEW.freeze_changed_timestamp:=current_timestamp;
    NEW.billing_status = 'CONFIRMED';

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.bills
  FOR EACH ROW
EXECUTE PROCEDURE inventories.bills_pre_process();


-- 請求:登録「後」処理
--  別テーブルの作成(入金充当)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.apply_deposit_from_bill() RETURNS TRIGGER AS $$
BEGIN
  IF (OLD.amount_confirmed_date IS NULL AND NEW.amount_confirmed_date IS NOT NULL) THEN
    CALL inventories.apply_deposit(NEW.costomer_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT OR UPDATE
  ON inventories.bills
  FOR EACH ROW
EXECUTE PROCEDURE inventories.apply_deposit_from_bill();


-- 請求登録/金額更新
-- Create Function
CREATE OR REPLACE FUNCTION inventories.upsert_bills_for_cutoff_date(
  i_costomer_id text,
  i_cut_off_date date,
  i_deposit_limit_date date,
  i_variable_amount numeric,
  i_create_by text
) RETURNS text AS $$
DECLARE
  rec RECORD;
  r_billing_id text;
BEGIN
  SELECT * INTO rec FROM inventories.bills
    WHERE  costomer_id = i_costomer_id AND cut_off_date = i_cut_off_date AND deposit_limit_date = i_deposit_limit_date
    FOR UPDATE;

  IF rec IS NULL THEN
    INSERT INTO inventories.bills VALUES (
      default,
      i_costomer_id,
      i_cut_off_date,
      i_deposit_limit_date,
      i_variable_amount,
      default,
      default,
      default,
      NULL,
      NULL,
      default,
      default,
      i_create_by,
      i_create_by
    ) RETURNING billing_id INTO r_billing_id;
    RETURN r_billing_id;

  ELSE
    UPDATE inventories.bills
    SET billing_amount = rec.billing_amount + i_variable_amount,
        updated_by = i_create_by
    WHERE  billing_id = rec.billing_id;
    RETURN rec.billing_id;
  END IF;

END;
$$ LANGUAGE plpgsql;


-- 請求:チェック制約
--  属性相関チェック制約(締日付/入金期限日付)

-- Create Constraint
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS deposit_limit_date_check;
ALTER TABLE inventories.bills ADD CONSTRAINT deposit_limit_date_check CHECK (
  cut_off_date < deposit_limit_date
);

-- 請求:チェック制約
--  属性相関チェック制約(締日付/金額確定日付)

-- Create Constraint
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.bills ADD CONSTRAINT amount_confirmed_date_check CHECK (
  cut_off_date < amount_confirmed_date
);


-- 入金:登録「前」処理
--  導出属性の算出:登録時のみ(入金ID)
--  導出属性の算出(残額)
--  有効桁数調整(入金金額/充当済金額)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.deposits_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(入金ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.deposit_id:='DP-'||to_char(nextval('inventories.deposit_no_seed'),'FM0000000');
  END IF;

  -- 有効桁数調整(入金金額/充当済金額)
  NEW.deposit_amount = ROUND(NEW.deposit_amount, 2);
  NEW.applied_amount = ROUND(NEW.applied_amount, 2);

--  導出属性の算出(残額)
  NEW.remaining_amount = ROUND(NEW.deposit_amount - NEW.applied_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.deposits
  FOR EACH ROW
EXECUTE PROCEDURE inventories.deposits_pre_process();


-- 入金:登録「後」処理
--  別テーブルの作成(入金充当)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.apply_deposit_from_deposit() RETURNS TRIGGER AS $$
BEGIN
  CALL inventories.apply_deposit(NEW.costomer_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.deposits
  FOR EACH ROW
EXECUTE PROCEDURE inventories.apply_deposit_from_deposit();
