$regfile = "m16def.dat"
$crystal = 8000000

Config Lcdbus = 4
Config Lcd = 16 * 2
Config Lcdpin = Pin, E = PortA.4, RS = PortA.5, Db4 = PortA.3, Db5 = PortA.2, Db6 = PortA.1, Db7 = PortA.0

' Define menu states
Const stIdle = 0
Const stMainMenu = 1
Const stLED = 2
Const stTemp = 3

' Control variables
Dim State As Byte           ' Current state
Dim MenuIndex As Byte       ' Selected menu option (0 or 1)
Dim LedState As Bit         ' LED status (0 = OFF, 1 = ON)
Dim TempThreshold As Single   ' Temperature threshold value
Dim stateChanged As Bit     ' Flag for state or menu change
Dim TempLM35 As Single      ' Temperature variable in Celsius
Dim TempADC As Word         ' Temperature variable in ADC format

' Pin configuration
Config Portb.0 = Output    ' LED is connected to PortC.0
Config Portb.1 = Output    ' Cooling fan
Config PortD.3 = Input     ' UP button (for navigation)
Config PortD.4 = Input     ' DOWN button
Config Porta.6 = Input     ' LM35 sensor input
PortD.3 = 0                ' Enable internal pull-down
PortD.4 = 0
Config ADC=Single, prescaler=AUTO, reference=INTERNAL_2.56       ' ADC configuration

' External interrupt INT0 configuration (center button)
On Int0 PushButtonInterrupt
Config Int0 = Falling      ' Enable interrupt on falling edge
Enable Int0
Enable Interrupts