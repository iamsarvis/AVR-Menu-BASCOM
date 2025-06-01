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

' Initial values
State = stIdle
MenuIndex = 0
LedState = 0
TempThreshold = 25         ' Default temperature threshold
stateChanged = 1           ' For displaying initial message

' Main program loop
Do
   ' Read LM35 value
   If State = stIdle Then
      TempADC = getADC(6)
      TempLM35 = TempADC*0.25
      Locate 2, 1
      If TempLM35 < TempThreshold Then
         Lcd "Temp : "; TempLM35; "      "
         Reset portb.1
      Else
         Lcd "Over Heat!Fan:on"
         Set portb.1
      End IF
   End If
   ' Update display if state or parameter has changed
   If stateChanged = 1 Then
      stateChanged = 0
      Cls
      Select Case State
         Case stIdle
            Locate 1, 1
            Lcd "Press MENU..."
         Case stMainMenu
            ' Display main menu with '>' showing selected option
            Locate 1, 1
            If MenuIndex = 0 Then
               Lcd "> LED Control"
            Else
               Lcd "  LED Control"
            End If
            Locate 2, 1
            If MenuIndex = 1 Then
               Lcd "> Set Temp Thr"
            Else
               Lcd "  Set Temp Thr"
            End If
         Case stLED
            ' LED control status
            Locate 1, 1
            Lcd "LED Control"
            Locate 2, 1
            If LedState = 1 Then
               Lcd "Status: ON "
            Else
               Lcd "Status: OFF"
            End If
         Case stTemp
            ' Set temperature threshold
            Locate 1, 1
            Lcd "Set Temp Thr"
            Locate 2, 1
            Lcd "Value: "; TempThreshold
      End Select
   End If

   ' Read UP/DOWN buttons in menu states
   If State = stMainMenu Or State = stLED Or State = stTemp Then
      ' UP button
      If Pind.3 = 1 Then
         Do: Loop Until Pind.3 = 0
         If State = stMainMenu Then
            If MenuIndex > 0 Then
               MenuIndex = MenuIndex - 1
               stateChanged = 1
            End If
         ElseIf State = stLED Then
            LedState = 1
            stateChanged = 1
         ElseIf State = stTemp Then
            If TempThreshold < 100 Then
               TempThreshold = TempThreshold + 1
               stateChanged = 1
            End If
         End If
      End If
      ' DOWN button
      If Pind.4 = 1 Then
         Do: Loop Until Pind.4 = 0
         If State = stMainMenu Then
            If MenuIndex < 1 Then
               MenuIndex = MenuIndex + 1
               stateChanged = 1
            End If
         ElseIf State = stLED Then
            LedState = 0
            stateChanged = 1
         ElseIf State = stTemp Then
            If TempThreshold > 0 Then
               TempThreshold = TempThreshold - 1
               stateChanged = 1
            End If
         End If
      End If
   End If

Loop
END

' INT0 interrupt (center button)
PushButtonInterrupt:
   If State = stIdle Then
      State = stMainMenu
      MenuIndex = 0
      stateChanged = 1
   ElseIf State = stMainMenu Then
      If MenuIndex = 0 Then
         State = stLED
      Else
         State = stTemp
      End If
      stateChanged = 1
   ElseIf State = stLED Or State = stTemp Then
      State = stIdle
      portb.0 = LedState
      stateChanged = 1
   End If
Return