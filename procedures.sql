CREATE OR REPLACE PROCEDURE GENERATE_BILL
(
 order_id IN INT,
 ssn IN INT,
 insurance_id IN INT 
) AS 
total_amount NUMBER;
copayment_percentage NUMBER;
copayment_amount NUMBER; -- this is the amount insurance company pays
customer_payment NUMBER; -- this is the amount customer pays
BEGIN 
 -- do a total of all orders
 SELECT SUM('price')
 INTO total_amount
 FROM ORDERED_DRUGS
 WHERE 'order_id' = order_id;
 -- get insurance details
 SELECT co_insurance
 INTO copayment_percentage
 FROM INSURANCE
 WHERE 'insurance_id' = insurance_id;
 -- the insurance company will pay this amount
 copayment_amount = total_amount * copayment_percentage;
 -- the customer will pay this amount
 customer_payment = total_amount * (1 - copayment_percentage);
 -- Insert data
 INSERT INTO BILL VALUES (order_id, ssn, total_amount, customer_payment, copayment_amount);
 END;


CREATE OR REPLACE 
PROCEDURE ADD_DRUG_TO_ORDER
 (
 order_id IN INT,
 drug_name IN CHAR(255),
 quantity IN INT 
 )
AS 
 drug MEDICINE%ROWTYPE;
 insufficient_quantity EXCEPTION;
 BEGIN 
 SELECT *
 INTO drug
 FROM MEDICINE
 WHERE 'drug_name' = drug_name;
 IF drug.quantity < quantity
 THEN 
 RAISE insufficient_quantity;
 ELSE 
 INSERT INTO ORDERED_DRUGS
 VALUES (order_id, drug.drug_name, drug.batch_number, quantity, drug.price);
 DBMS_OUTPUT.PUT_LINE("Drug added successfully to the order");
 END IF;
 EXCEPTION 
 WHEN insufficient_quantity THEN 
 DBMS_OUTPUT.PUT_LINE(
 "Request drug " || drug_name || " is not available. Maximum order possible is " || drug.quantity
 );
 END;
 
 
 CREATE OR REPLACE 
PROCEDURE REPORT_EXPIRING_DRUGS
AS 
 BEGIN 
 DBMS_OUTPUT.PUT_LINE('ALL DRUGS EXPIRING IN NEXT 60 DAYS');
 -- date calculations from
 -- http://www.oracle.com/technetwork/issue-archive/2012/12-jan/o12plsql-1408561.html
 FOR item IN 
 (
 SELECT 
 'drug_name',
 'batch_number',
 'manufacturer',
 'stock_quantity',
 'expiry_date'
 FROM MEDICINE
 WHERE 'expiry_date' < SYSDATE + 60
 )
 LOOP 
 DBMS_OUTPUT.PUT_LINE(
 item.drug_name || item.batch_number || item.manufacturer || item.stock_quantity || item.expiry_date)
 END LOOP;
 END;
 
 
 CREATE OR REPLACE 
PROCEDURE DISPOSE_DRUGS
 (
 drug_name IN CHAR(255),
 batch_number IN INT,
 employee_id IN INT 
 )
AS 
 medicine MEDICINE%ROWTYPE;
 new_notification_id INT;
 notification_message CHAR(1000);
 BEGIN 
 SELECT *
 INTO medicine
 FROM MEDICINE
 WHERE MEDICINE.drug_name = drug_name AND MEDICINE.batch_number = batch_number
 AND MEDICINE.expiry_date <= SYSDATE;
 IF medicine%FOUND 
 THEN 
 INSERT INTO DISPOSE_DRUGS VALUES (drug_name, batch_number, medicine.quantity, 
medicine.manufacturer);
 INSERT INTO "EMPLOYEE_DISPOSED_DRUGS" VALUES (employee_id, drug_name, batch_number, 
SYSDATE);
 DELETE FROM MEDICINE
 WHERE MEDICINE.drug_name = drug_name AND MEDICINE.batch_number AND MEDICINE.expiry_date < 
SYSDATE;
 -- Operations are done, we have to send notification now
 SELECT MAX(ID) + 1
 INTO new_notification_id
 FROM NOTIFICATION;
 notification_message = 'Successfully Disposed: ' || drug_name || '(' || batch_number || ') by Employee' ||
 INSERT INTO NOTIFICATION VALUES (new_notification_id, notification_message, 'DISPOSAL_SUCCESS');
 -- SEND NOTIFICATION TO EMPLOYEES
 EXECUTE IMMEDIATE SEND_NOTIFICATIONS(new_notification_id, 'pharmacist');
 END IF;
 END;


CREATE OR REPLACE 
PROCEDURE SEND_NOTIFICATIONS
 (
 notification_id IN INT,
 employee_role IN CHAR(100)
 )
AS 
 BEGIN 
 FOR employee IN 
 (
 SELECT 'ID'
 FROM EMPLOYEE
 WHERE LOWER(EMPLOYEE.role) = employee_role
 )
 LOOP 
 INSERT INTO EMPLOYEE_NOTIFICATIONS VALUES (employee, notification_id);
 END LOOP;
 END;
