CREATE TRIGGER Low_Stock_Alert
AFTER INSERT | UPDATE ON MEDICINE
FOR EACH ROW 
 DECLARE 
 new_notification_id INT;
 BEGIN 
 
 IF:
 NEW.stock_quantity < 100
 THEN 
 SELECT MAX(ID) + 1
 INTO new_notification_id
 FROM NOTIFICATION;
 INSERT INTO NOTIFICATION VALUES (new_notification_id,
 :OLD.drug_name || ' batch - ' || :OLD.batch_number || ' has low stock. Only ' ||
 :NEW:quantity || ' in stock', 'LOWSTOCK');
 -- Send notification to Pharmacists
 EXECUTE IMMEDIATE_SEND_NOTIFICATIONS(new_notification_id, 'pharmacist');
 END IF;
 END;
 
 
 CREATE TRIGGER Validate_Employee
BEFORE INSERT OR UPDATE ON EMPLOYEE
FOR EACH ROW 
 BEGIN 
 IF LOWER(:NEW.role) != 'cashier' OR LOWER(:NEW.role != 'pharmacist') OR LOWER(:NEW.role != 'cpht') OR 
 LOWER(:NEW.role != 'intern')
 THEN 
 RAISE_APPLICATION_ERROR(-20000, 'Invalid role given for employee');
 END IF;
 IF :NEW.license := NULL AND LOWER(:new.role) != 'cashier'
 THEN 
 RAISE_APPLICATION_ERROR(-20000, 'Can not leave license blank for anyone except cashiers');
 END IF;
 END;
 
 