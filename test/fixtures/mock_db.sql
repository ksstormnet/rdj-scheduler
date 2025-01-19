-- Mock database for testing
CREATE TABLE IF NOT EXISTS `category` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `name` (`name`)
);

CREATE TABLE IF NOT EXISTS `subcategory` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `parentid` int(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`)
);

CREATE TABLE IF NOT EXISTS `events` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `type` int(2) NOT NULL,
  `time` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `date` date DEFAULT '2002-01-01',
  `day` varchar(30) DEFAULT '&',
  `hours` varchar(100) DEFAULT '&',
  `data` text DEFAULT NULL,
  `enabled` enum('True','False') DEFAULT 'True',
  `catID` int(10) NOT NULL DEFAULT 0,
  `smart` int(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`)
);

CREATE TABLE IF NOT EXISTS `rotations` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `name` (`name`)
);

CREATE TABLE IF NOT EXISTS `rotations_list` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `pID` int(10) NOT NULL,
  `catID` int(10) NOT NULL,
  `subID` int(10) NOT NULL,
  `genID` int(10) NOT NULL DEFAULT 0,
  `mood` varchar(250) DEFAULT NULL,
  `gender` varchar(250) DEFAULT NULL,
  `language` varchar(250) DEFAULT NULL,
  `start_type` int(11) NOT NULL DEFAULT 0,
  `end_type` int(11) NOT NULL DEFAULT 0,
  `selType` int(1) NOT NULL DEFAULT 0,
  `sweeper` int(1) NOT NULL DEFAULT 0,
  `repeatRule` set('True','False') NOT NULL DEFAULT 'False',
  `ord` int(2) NOT NULL,
  `data` text NOT NULL,
  `track_separation` int(11) NOT NULL DEFAULT 0,
  `artist_separation` int(11) NOT NULL DEFAULT 0,
  `title_separation` int(11) NOT NULL DEFAULT 0,
  `album_separation` int(11) NOT NULL DEFAULT 0,
  `advanced` text DEFAULT NULL,
  PRIMARY KEY (`ID`)
);

-- Sample test data
INSERT INTO `category` (`ID`, `name`) VALUES 
(1, 'Music'),
(2, 'Jingles'),
(3, 'Commercials');

INSERT INTO `subcategory` (`ID`, `parentid`, `name`) VALUES
(1, 1, 'Rock'),
(2, 1, 'Pop'),
(3, 2, 'Station ID'),
(4, 3, 'Local Ads');

INSERT INTO `rotations` (`ID`, `name`) VALUES
(1, 'Daytime'),
(2, 'Evening'),
(3, 'Overnight');

INSERT INTO `rotations_list` 
(`ID`, `pID`, `catID`, `subID`, `genID`, `selType`, `sweeper`, `ord`, `data`, `repeatRule`) VALUES
(1, 1, 1, 1, 0, 0, 0, 1, '', 'False'),
(2, 1, 2, 3, 0, 0, 1, 2, '', 'True'),
(3, 2, 1, 2, 0, 0, 0, 1, '', 'False');

INSERT INTO `events` (`ID`, `type`, `time`, `name`, `day`, `hours`, `enabled`, `catID`, `smart`) VALUES
(1, 2, '08:00:00', 'Morning Show Rotation', '&1&2&3&4&5', '&6&7&8&9', 'True', 1, 0),
(2, 2, '12:00:00', 'All Day Event', '&', '&', 'True', 2, 1),
(3, 2, '18:00:00', 'Evening Rotation', '&0', '&18&19&20&21', 'True', 1, 0);
