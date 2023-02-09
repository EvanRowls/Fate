HotKeySet("{-}", "Stop")
HotKeySet("+{esc}", "Terminate")
HotKeySet("{o}", "Restart")

Global $Paused
Global $Started
Global $isfishing
Global $counter = 0
Global $pet_in_town = false


Launch()
Main()

Func Launch() ;Launch or switch to FATE
	;Run or switch to Fate
	If Not WinExists("FATE") Then
		Run("C:\Program Files (x86)\Steam\steamapps\common\FATE\fate.exe") ;Run Fate
		Local $launching = 1
		While $launching ;Wait for main menu to load
			Local $Launched = PixelSearch(170, 450, 200, 470, 0xB886F8)
			If @error Then
				ToolTip("Launching...", 0, 0)
				Sleep(200)
			Else
				$launching = 0 ;Main Menu Loaded
				MouseClick("", 360, 456) ;click continue game
				Sleep(100)
				MouseClick("", 1539, 937) ;click load game
			EndIf
		WEnd
		Local $loading = 1
		While $loading     ;Wait for game to load
			PixelSearch(450, 948, 524, 998, 0xCECECE)
			If @error Then
				ToolTip("Loading...", 0, 0)
				Sleep(200)
			Else
				ToolTip("Loaded!", 0, 0)
				$loading = 0 ;Game is loaded
				ToolTip("") ;Clear Tooltip
				Send("{l}") ;Pause after Load
			EndIf
		WEnd
	Else
		WinActivate("FATE") ;Switch to Fate
		MouseClick("", 955, 596) ;Click Resume game
		Send("{l}") ;Pause script
	EndIf
EndFunc   ;==>Launch

Func Main()
	While WinExists("FATE")
		$Started = 1 ;game is running
		Do
			ToolTip("")
			;Start fishing
			StartFishing()
			
			;Bite
			Reel_In()
		Until $Started = 0 ;Game has closed
	WEnd
	Exit ;Kills script on game close
EndFunc   ;==>Main

Func StartFishing() ;Finds and clicks on fishing spot
	$isfishing = 0
	Sleep(100)
	While Not $isfishing ;Only run if not fishing
		ToolTip("Searching for water" & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0)
		Global $findWater = PixelSearch(800, 250, 1200, 700, 0x3A9985, 10, 3) ;Look for water
		If Not @error Then
			ToolTip("Water found at " & $findWater[0] & ", " & $findWater[1] & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0)
			MouseMove($findWater[0], $findWater[1], 0) ;Show where water was found
			Local $waterFound = 1
			While $waterFound
				If $Started Then
					Local $fishingSpot = PixelSearch($findWater[0] - 200, $findWater[1] - 200, $findWater[0] + 200, $findWater[1] + 200, 0xF5FFA5, 5) ;Search for fishing spot marker near where water was found
					If Not @error Then
						ToolTip("Fishing spot found at " & $fishingSpot[0] & ", " & $fishingSpot[1] & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0)
						MouseClick("Left", $fishingSpot[0], $fishingSpot[1]) ;click fishing spot
						Sleep(200)
						PixelSearch(900, 700, 1000, 800, 0xBD8AFF) ;Check if fishing
						If Not @error Then
							$isfishing = 1 ;Finished fishing cycle
							$waterFound = 0 ;Search for water again
						EndIf
					EndIf
				EndIf
			WEnd
		EndIf
	WEnd
EndFunc   ;==>StartFishing

Func Reel_In() ;Clicks "Set hook" on bite
	While $isfishing
		If WinExists("FATE") Then
			ToolTip("Now we wait!" & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0)
			Sleep(100)
			PixelSearch(918, 320, 1006, 522, 0xE76517) ;Watch for bite marker
			If Not @error Then
				ToolTip("Got One!" & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0)
				MouseClick("Left", 948, 756) ;Reel In
				MouseClick("Left", 948, 756) ;Redundant click due to occaisonal miss
				$isfishing = 0 ;Start new fishing cycle
				Sleep(4500) ;wait for reel animation
				$counter += 1
				ToolTip("")
			EndIf
		Else
			Exit  ;kill script if game closes while fishing
		EndIf
		If $pet_in_town Then
			CheckPet()
		EndIf
	WEnd
	PixelSearch(929, 620, 990, 643, 0xBD8AFF) ;Find OK
	If Not @error Then
		ToolTip("Nice" & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0) ;Fish caught
		MouseClick("Left", 971, 649) ;click ok
	Else
		ToolTip("...or not" & @CRLF & "Attempts till next sell: " & 37-$counter, 0, 0) ;No fish Caught
		Sleep(200)
	EndIf
	CheckPet()
	If $counter == 37 Then ;Send pet to sell if inventory is full
		If $pet_in_town == false Then
			Sell()
		Else
			While $pet_in_town
				Sleep(5000)
				CheckPet()
			WEnd
		EndIf
	EndIf
EndFunc   ;==>Reel_In

Func Sell() ;Transfers fish to pet and send pet to town
	Sleep(100)
	Send("{i}");Open Player Inventory
	Sleep(100)
	Send("{p}");Open Pet Inventory
	Sleep(100)
	EmptyInventory()
	$counter = 0
	;Send Pet to Sell Fish
	MouseClick("left",77,180,1)
	MouseClick("left",782,823,1)
	$pet_in_town = true
EndFunc

Func EmptyInventory()
	;Transfer Everything
	ToolTip('Moving items', 0, 0)
	Send("{SHIFTDOWN}")
	MouseClick("left",1023,752,1)
	MouseClick("left",1107,747,1)
	MouseClick("left",1109,706,1)
	MouseClick("left",1122,618,1)
	MouseClick("left",1119,556,1)
	MouseClick("left",1188,546,1)
	MouseClick("left",1220,625,1)
	MouseClick("left",1228,694,1)
	MouseClick("left",1205,768,1)
	MouseClick("left",1204,768,1)
	MouseClick("left",1280,767,1)
	MouseClick("left",1290,685,1)
	MouseClick("left",1292,620,1)
	MouseClick("left",1286,557,1)
	MouseClick("left",1384,557,1)
	MouseClick("left",1392,636,1)
	MouseClick("left",1389,691,1)
	MouseClick("left",1388,691,1)
	MouseClick("left",1395,763,1)
	MouseClick("left",1488,757,1)
	MouseClick("left",1474,700,1)
	MouseClick("left",1473,608,1)
	MouseClick("left",1472,576,1)
	MouseClick("left",1561,567,1)
	MouseClick("left",1548,621,1)
	MouseClick("left",1566,692,1)
	MouseClick("left",1564,754,1)
	MouseClick("left",1660,758,1)
	MouseClick("left",1649,682,1)
	MouseClick("left",1640,630,1)
	MouseClick("left",1662,548,1)
	MouseClick("left",1751,554,1)
	MouseClick("left",1747,618,1)
	MouseClick("left",1746,697,1)
	MouseClick("left",1745,763,1)
	MouseClick("left",1830,757,1)
	MouseClick("left",1830,756,1)
	MouseClick("left",1817,682,1)
	MouseClick("left",1824,624,1)
	MouseClick("left",1836,573,1)
	Send("{SHIFTUP}")
	Send("{ESC}")
EndFunc

Func CheckPet() ; Check if pet is in town
	PixelSearch(42, 107, 61, 122, 0xFEFEFE)
	If @error Then
		$pet_in_town = false
		PetReturned()
	EndIf
EndFunc

Func PetReturned()
	Local $coords = PixelSearch(830, 600, 1050, 850, 0xBD8AFF)
	If Not @error Then
		MouseClick("Left", $coords[0], $coords[1],1)
	EndIf
EndFunc

Func Restart() ;Manually restarts fishing sequence in case it gets stuck
	$Started = 0
	Main()
EndFunc   ;==>Restart

Func Stop() ;Pauses script for when not fishing
	$Paused = Not $Paused ;change $Paused to opposite state
	While $Paused
		Sleep(100)
		ToolTip('Fishing is Paused, press - to auto fish', 0, 0)
		If Not WinExists("FATE") Then
			Exit ;kill script if game is closed
		EndIf
	WEnd
	ToolTip("")
EndFunc   ;==>Stop

Func Terminate() ;kill script with hot key
	Exit
EndFunc   ;==>Terminate
