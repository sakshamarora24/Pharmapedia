DROP TABLE if exists Customer;
CREATE TABLE Customer (
    SSN               int NOT NULL, 
    First_Name        char(255) NOT NULL, 
    Last_Name         char(255) NOT NULL, 
    Phone             int NOT NULL UNIQUE, 
    Gender            char(1) NOT NULL, 
    Address           char(255) NOT NULL, 
    DoB     		  date NOT NULL, 
    Insurance_ID      int UNIQUE, 

    PRIMARY KEY (SSN)
);

ALTER TABLE Customer ADD CONSTRAINT insures FOREIGN KEY (Insurance_ID) 
    REFERENCES Insurance (Insurance_ID) ON DELETE Set null;

DROP TABLE if exists Prescription;
CREATE TABLE Prescription (
    Prescription_ID   int NOT NULL, 
    SSN               int NOT NULL, 
    Doctor_ID         int NOT NULL, 
    Prescribed_Date   date NOT NULL, 
    
    PRIMARY KEY (Prescription_ID)
);

ALTER TABLE Prescription ADD CONSTRAINT holds FOREIGN KEY (SSN) 
    REFERENCES Customer (SSN);

CREATE TABLE Prescribed_Drugs (
    Prescription_ID       int NOT NULL, 
    Drug_Name             char(255) NOT NULL, 
    Prescribed_Quantity   int NOT NULL, 
    Refill_Limit          int NOT NULL, 
    
    PRIMARY KEY (Prescription_ID, Drug_Name)
);

ALTER TABLE Prescribed_Drugs ADD CONSTRAINT consists FOREIGN KEY (Prescription_ID) 
    REFERENCES Prescription (Prescription_ID) ON DELETE Cascade;

DROP TABLE if exists Orders;
CREATE TABLE Orders (
    Order_ID          int NOT NULL, 
    Prescription_ID   int NOT NULL, 
    EmployeeID        int NOT NULL, 
    Order_Date        date NOT NULL, 

    PRIMARY KEY (Order_ID)
);

ALTER TABLE Orders ADD CONSTRAINT prepares FOREIGN KEY (EmployeeID) 
    REFERENCES Employee (ID);
ALTER TABLE Orders ADD CONSTRAINT uses FOREIGN KEY (Prescription_ID) 
    REFERENCES Prescription (Prescription_ID);

CREATE TABLE Ordered_Drugs (
    Order_ID            int NOT NULL, 
    Drug_Name           char(255) NOT NULL, 
    Batch		        int NOT NULL, 
    Ordered_Quantity    int NOT NULL, 
    Price               int(2) NOT NULL, 

    PRIMARY KEY (Order_ID, Drug_Name, Batch)
);

ALTER TABLE Ordered_Drugs ADD CONSTRAINT contains FOREIGN KEY (Order_ID) 
    REFERENCES Orders (Order_ID) ON DELETE Cascade;
ALTER TABLE Ordered_Drugs ADD CONSTRAINT Fulfilled FOREIGN KEY (Drug_Name, Batch) 
    REFERENCES Medicine (Drug_Name, Batch);

DROP TABLE if exists Insurance;
CREATE TABLE Insurance (
    Insurance_ID    int NOT NULL, 
    Company_Name    char(255) NOT NULL, 
    Start_Date      date NOT NULL, 
    End_Date        date NOT NULL, 
    Co_Insurance    int NOT NULL, 
    
    PRIMARY KEY (Insurance_ID)
);

CREATE INDEX Insurance_Company_Name 
    ON Insurance (Company_Name);

DROP TABLE if exists Employee;
CREATE TABLE Employee (
    ID                int NOT NULL, 
    SSN               int NOT NULL UNIQUE, 
    License           int UNIQUE, 
    First_Name        char(255) NOT NULL, 
    Last_Name         char(255) NOT NULL, 
    Start_Date        date NOT NULL, 
    End_Date          date, 
    Role              char(255) NOT NULL, 
    Salary            int NOT NULL, 
    Phone		      int NOT NULL, 
    DoB			 	  date NOT NULL, 

    PRIMARY KEY (ID)
);

CREATE TABLE Medicine (
    Drug_Name           char(255) NOT NULL, 
    Batch               int NOT NULL, 
    MedicineType        char(255) NOT NULL, 
    Manufacturer        char(255) NOT NULL, 
    Stock_Quantity      int NOT NULL, 
    Expiry_Date         date NOT NULL, 
    Price               int NOT NULL, 

    PRIMARY KEY (Drug_Name, Batch)
);

CREATE TABLE Bill (
    Order_ID            int NOT NULL, 
    CustomerSSN         int NOT NULL, 
    Total_Amount        int NOT NULL, 
    Customer_Payment    int NOT NULL, 
    Insurance_Payment   int NOT NULL, 
    
    PRIMARY KEY (Order_ID, CustomerSSN)
);

ALTER TABLE Bill ADD CONSTRAINT makes FOREIGN KEY (Order_ID) 
    REFERENCES Orders (Order_ID);
ALTER TABLE Bill ADD CONSTRAINT pays FOREIGN KEY (CustomerSSN) 
    REFERENCES Customer (SSN);

CREATE TABLE Disposed_Drugs (
    Drug_Name       char(255) NOT NULL, 
    Batch           int NOT NULL, 
    Quantity        int NOT NULL, 
    Company         char(255) NOT NULL, 

    PRIMARY KEY (Drug_Name, Batch)
);

ALTER TABLE Disposed_Drugs ADD CONSTRAINT disposed FOREIGN KEY (Drug_Name, Batch) 
    REFERENCES Medicine (Drug_Name, Batch);

DROP TABLE if exists Notification;
CREATE TABLE Notification (
    ID              int NOT NULL, 
    Message         char(255) NOT NULL, 
    Type            char(255) NOT NULL, 

    PRIMARY KEY (ID)
);

CREATE TABLE Employee_Notification (
    EmployeeID        int NOT NULL, 
    NotificationID    int NOT NULL, 
    
    PRIMARY KEY (EmployeeID, NotificationID)
);

ALTER TABLE Employee_Notification ADD CONSTRAINT FKEmployee_N849182 FOREIGN KEY (EmployeeID) 
    REFERENCES Employee (ID) ON DELETE Cascade;
ALTER TABLE Employee_Notification ADD CONSTRAINT FKEmployee_N664471 FOREIGN KEY (NotificationID) 
    REFERENCES Notification (ID) ON DELETE Cascade;

CREATE TABLE Employee_Disposed_Drugs (
    EmployeeID        int NOT NULL, 
    Drug_Name         char(255) NOT NULL, 
    Batch             int NOT NULL, 
    Disposal_Date     date NOT NULL, 
    
    PRIMARY KEY (EmployeeID, Drug_Name, Batch, Disposal_Date)
);

ALTER TABLE Employee_Disposed_Drugs ADD CONSTRAINT FKEmployee_D470142 FOREIGN KEY (EmployeeID) 
    REFERENCES Employee (ID);
ALTER TABLE Employee_Disposed_Drugs ADD CONSTRAINT FKEmployee_D990025 FOREIGN KEY (Drug_Name, Batch) 
    REFERENCES Disposed_Drugs (Drug_Name, Batch);
