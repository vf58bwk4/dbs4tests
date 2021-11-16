DROP DATABASE IF EXISTS northwind;
CREATE DATABASE IF NOT EXISTS northwind;
USE northwind;

DROP TABLE IF EXISTS order_details, -- orderID, productID
                     orders, -- customerID, employeeID, shipVia::shippers
                     products, -- supplierID, categoryID
                     customers, 
                     employee_territories, -- employeeID, territoryID
                     employees, 
                     territories, -- regionID
                     regions,
                     categories,
                     shippers,
                     suppliers;

CREATE TABLE suppliers (
    supplierID      INT         NOT NULL,
    companyName     VARCHAR(50) NOT NULL,
    contactName     VARCHAR(40) NOT NULL,
    contactTitle    VARCHAR(40) NOT NULL,
    address         VARCHAR(50) NOT NULL,
    city            VARCHAR(20) NOT NULL,
    region          VARCHAR(15),
    postalCode      VARCHAR(10) NOT NULL,
    country         VARCHAR(15) NOT NULL,
    phone           VARCHAR(20) NOT NULL,
    fax             VARCHAR(20),
    homePage        VARCHAR(100),
    PRIMARY KEY (supplierID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/suppliers.csv'
    INTO TABLE suppliers
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES
    (supplierID,companyName,contactName,contactTitle,address,city,@vregion,postalCode,country,phone,@vfax,@vhomePage)
    SET 
      region = NULLIF(@vregion,'NULL'),
      fax = NULLIF(@vfax, 'NULL'),
      homePage = NULLIF(@vhomePage,'NULL');

CREATE TABLE shippers (
    shipperID       INT         NOT NULL,
    companyName     VARCHAR(40) NOT NULL,
    phone           VARCHAR(20) NOT NULL,
    PRIMARY KEY (shipperID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/shippers.csv'
    INTO TABLE shippers
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;

CREATE TABLE categories (
    categoryID      INT         NOT NULL,
    categoryName    VARCHAR(20) NOT NULL,
    description     VARCHAR(60) NOT NULL,
    picture         TEXT        NOT NULL,
    PRIMARY KEY (categoryID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/categories.csv'
    INTO TABLE categories
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;

CREATE TABLE regions (
    regionID            INT         NOT NULL,
    regionDescription   VARCHAR(10) NOT NULL,
    PRIMARY KEY (regionID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/regions.csv'
    INTO TABLE regions
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;

CREATE TABLE territories (
    territoryID             INT         NOT NULL,
    territoryDescription    VARCHAR(20) NOT NULL,
    regionID                INT         NOT NULL,
    FOREIGN KEY (regionID)  REFERENCES regions (regionID)   ON DELETE CASCADE,
    PRIMARY KEY (territoryID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/territories.csv'
    INTO TABLE territories
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;

CREATE TABLE employees (
    employeeID          INT         NOT NULL,
    lastName            VARCHAR(15) NOT NULL,
    firstName           VARCHAR(15) NOT NULL,
    title               VARCHAR(30) NOT NULL,
    titleOfCourtesy     VARCHAR(4)  NOT NULL,
    birthDate           DATE        NOT NULL,
    hireDate            DATE        NOT NULL,
    address             VARCHAR(50) NOT NULL,
    city                VARCHAR(20) NOT NULL,
    region              VARCHAR(15),
    postalCode          VARCHAR(10) NOT NULL,
    country             VARCHAR(15) NOT NULL,
    homePhone           VARCHAR(20) NOT NULL,
    extension           VARCHAR(10),
    photo               TEXT        NOT NULL,
    notes               TEXT        NOT NULL,
    reportsTo           INT,
    photoPath           VARCHAR(50),
    FOREIGN KEY (reportsTo) REFERENCES employees (employeeID),
    PRIMARY KEY (employeeID)
);

SET FOREIGN_KEY_CHECKS=0;

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/employees.csv'
    INTO TABLE employees
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES
	 (employeeID,lastName,firstName,title,titleOfCourtesy,birthDate,hireDate,address,city,@vregion,postalCode,country,homePhone,@vextension,photo,notes,@vreportsTo,@vphotoPath)
	 SET
	   region = NULLIF(@vregion,'NULL'),
	   extension = NULLIF(@vextension,'NULL'),
	   reportsTo = NULLIF(@vreportsTo,'NULL'),
	   photoPath = NULLIF(@vphotoPath,'NULL');

SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE employee_territories (
    employeeID  INT NOT NULL,
    territoryID INT NOT NULL,
    FOREIGN KEY (employeeID)    REFERENCES employees (employeeID)       ON DELETE CASCADE,
    FOREIGN KEY (territoryID)   REFERENCES territories (territoryID)    ON DELETE CASCADE,
    PRIMARY KEY (employeeID,territoryID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/employee_territories.csv'
    INTO TABLE employee_territories
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;

CREATE TABLE customers (
    customerID      CHAR(5)     NOT NULL,
    companyName     VARCHAR(50) NOT NULL,
    contactName     VARCHAR(40) NOT NULL,
    contactTitle    VARCHAR(40) NOT NULL,
    address         VARCHAR(50) NOT NULL,
    city            VARCHAR(20) NOT NULL,
    region          VARCHAR(15),
    postalCode      VARCHAR(10) NOT NULL,
    country         VARCHAR(15) NOT NULL,
    phone           VARCHAR(20) NOT NULL,
    fax             VARCHAR(20),
    PRIMARY KEY (customerID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/customers.csv'
    INTO TABLE customers
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES
	 (customerID,companyName,contactName,contactTitle,address,city,@vregion,postalCode,country,phone,@vfax)
	 SET
	   region = NULLIF(@vregion,'NULL'),
	   fax = NULLIF(@vfax,'NULL');
	   
CREATE TABLE products (
    productID           INT             NOT NULL,
    productName         VARCHAR(50)     NOT NULL,
    supplierID          INT             NOT NULL,
    categoryID          INT             NOT NULL,
    quantityPerUnit     VARCHAR(20)     NOT NULL,
    unitPrice           DECIMAL(10,2)   NOT NULL,
    unitsInStock        INT             NOT NULL,
    unitsOnOrder        INT             NOT NULL,
    reorderLevel        INT             NOT NULL,
    discontinued        INT             NOT NULL,
    FOREIGN KEY (supplierID)    REFERENCES suppliers (supplierID)   ON DELETE CASCADE,
    FOREIGN KEY (categoryID)    REFERENCES categories (categoryID)  ON DELETE CASCADE,
    PRIMARY KEY (productID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/products.csv'
    INTO TABLE products
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;

CREATE TABLE orders (
    orderID         INT         NOT NULL,
    customerID      CHAR(5)     NOT NULL,
    employeeID      INT         NOT NULL,
    orderDate       DATE        NOT NULL,
    requiredDate    DATE        NOT NULL,
    shippedDate     DATE,
    shipVia         INT         NOT NULL,
    freight         DECIMAL(7,2)NOT NULL,
    shipName        VARCHAR(50) NOT NULL,
    shipAddress     VARCHAR(50) NOT NULL,
    shipCity        VARCHAR(20) NOT NULL,
    shipRegion      VARCHAR(15),
    shipPostalCode  VARCHAR(10) NOT NULL,
    shipCountry     VARCHAR(15) NOT NULL,
    FOREIGN KEY (customerID)    REFERENCES customers (customerID)   ON DELETE CASCADE,
    FOREIGN KEY (employeeID)    REFERENCES employees (employeeID)   ON DELETE CASCADE,
    FOREIGN KEY (shipVia)       REFERENCES shippers (shipperID)     ON DELETE CASCADE,
    PRIMARY KEY (orderID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/orders.csv'
    INTO TABLE orders
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES
	 (orderID,customerID,employeeID,orderDate,requiredDate,@vshippedDate,shipVia,freight,shipName,shipAddress,shipCity,@vshipRegion,shipPostalCode,shipCountry)
	 SET
	   shippedDate = NULLIF(@vshippedDate,'NULL'),
	   shipRegion = NULLIF(@vshipRegion,'NULL');

CREATE TABLE order_details (
    orderID     INT         NOT NULL,
    productID   INT         NOT NULL,
    unitPrice   DECIMAL(7,2)NOT NULL,
    quantity    INT         NOT NULL,
    discount    DECIMAL(2,2)NOT NULL,
    FOREIGN KEY (orderID)   REFERENCES orders (orderID)     ON DELETE CASCADE,
    FOREIGN KEY (productID) REFERENCES products (productID) ON DELETE CASCADE,
    PRIMARY KEY (orderID,productID)
);

LOAD DATA
    INFILE 'C:/local/test_db/northwind/csv/order_details.csv'
    INTO TABLE order_details
    FIELDS TERMINATED BY ','
    IGNORE 1 LINES;
orders