CREATE TABLE IF NOT EXISTS gunrange_scores (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(50) NOT NULL,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    difficulty INT NOT NULL,
    difficulty_name VARCHAR(50) NOT NULL,
    score INT NOT NULL,
    targets INT NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
