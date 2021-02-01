CREATE DATABASE temp;
-- DROP DATABASE temp;
USE temp;

-- SET GLOBAL local_infile = 1;
-- SET GLOBAL local_infile = 0;
SHOW GLOBAL VARIABLES LIKE "%infile%";
-- SET OPT_LOCAL_INFILE = 1;

CREATE TABLE CreditCard2 (
	store_id		INT,			-- 각 파일에서의 상점 고유 번호
	date			DATETIME,		-- 거래 일자
	time			TIME,			-- 거래 시간
	card_id			VARCHAR(40),	-- 카드 번호의 hash 값
	amount			INT,			-- 매출액, 0보다 작은 음수는 거래 취소(환불)
	installments	INT,			-- 할부개월수, 일시불은 빈 문자열
	days_of_week	INT,			-- 요일, 월요일이 0, 일요일은 6
	holyday			INT				-- 1이면 공휴일, 0이면 공휴일 아님
);
DESCRIBE CreditCard2;
-- DROP TABLE CreditCard;

CREATE TABLE testing (
	store_id		INT,			-- 각 파일에서의 상점 고유 번호
    card_id			INT,
    card_company	VARCHAR(40),
    trasacted_date	VARCHAR(40),
    transacted_time VARCHAR(40),
    installment_term 	varchar(40),
    region		VARCHAR(40),
    type_of_business	VARCHAR(40),
    amount	int
);
DESCRIBE testing;
LOAD DATA LOCAL INFILE "C:\\Github Projects\\2021-winter-project\\funda_train.csv"
INTO TABLE testing
FIELDS TERMINATED BY ','
LINES TERMINATED BY "\r\n"
IGNORE 1 ROWS;

SELECT MAX(store_id)
FROM CreditCard;
-- 1799

SELECT COUNT(DISTINCT store_id)
FROM CreditCard;

-- 데이터 확인 및 분석 과정
SELECT * FROM CreditCard2 LIMIT 5;

SELECT MIN(amount), MAX(amount), AVG(amount)
FROM CreditCard;
