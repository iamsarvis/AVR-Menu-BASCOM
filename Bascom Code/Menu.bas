$regfile = "m16def.dat"
$crystal = 8000000

Config Lcdbus = 4
Config Lcd = 16 * 2
Config Lcdpin = Pin, E = PortA.4, RS = PortA.5, Db4 = PortA.3, Db5 = PortA.2, Db6 = PortA.1, Db7 = PortA.0
