CREATE TABLE `gangsbuilder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `society` varchar(50) NOT NULL,
  `blipcoords` varchar(255) NOT NULL,
  `zone` varchar(255) NOT NULL,
  `bliplabel` varchar(255) NOT NULL,
  `blipsprite` varchar(255) NOT NULL,
  `blipcouleur` varchar(255) NOT NULL,
  `bliptaille` varchar(255) NOT NULL,
  `pointvestiaire` varchar(255) NOT NULL,
  `pointgarage` varchar(255) NOT NULL,
  `pointcoffre` varchar(255) NOT NULL,
  `pointboss` varchar(255) NOT NULL,
  `pointspawnveh` varchar(255) NOT NULL,
  `headingspawnveh` varchar(255) NOT NULL,
  `pointrangementveh` varchar(255) NOT NULL,

  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;