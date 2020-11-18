; Script Information ===========================================================
; Name:        ahk Tester
; Description: blank script for testing small snippets of script
; AHK Version: AHK 1.1.30.00
; Author:      James Clarke JClarke.SW@Gmail.com 
; ==============================================================================

; Revision History =============================================================
; Revision 1 (18/6/19)
; * Initial release
; ==============================================================================

; Load Function ================================================================
    OnLoad() {
        Global ; Assume-global mode
        Static Init := OnLoad() ; Call function
        OutputDebug, ############## COMMENCED ##############
        Menu, Tray, Tip, AHK Tester
        Menu, Tray, Icon, tester.ico
        
        OutputDebug, ############## STANDARD CALLS COMPLETED ##############

        OutputDebug, ############## FINISHED ##############
    }

; ==============================================================================

; Auto-Execute =================================================================
    OutputDebug, ^^^^^^^^^^^^^ AutoExecute ^^^^^^^^^^^^^
    ;   Environmentals
        #SingleInstance, Force ; Allow only one running instance of script
        #Persistent ; Keep the script permanently running until terminated
        #NoEnv ; Avoid checking empty variables for environment variables
        #Warn ; Enable warnings to assist with detecting common errors
        ;#NoTrayIcon ; Disable the tray icon of the script
        SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

    ;   Operation
        SetBatchLines, -1 ; The speed at which the lines of the script are executed
        #KeyHistory 1       ;  0 - No Keyhistory 
        ListLines  On       ; Off  - for more speed 

        SendMode, Input ; The method for sending keystrokes and mouse clicks
        SetKeyDelay, 10, 10   ; for speed -1, -1, 
        SetMouseDelay, 25       ;0 recommend -1 for max speed 
        SetDefaultMouseSpeed, 0     ;0-100 
        ;SetControlDelay, -1 ; The delay to occur after modifying a control

        SetTitleMatchMode, 2
        SetTitleMatchMode Fast  ;slow detect hidden windows
        SetWinDelay, 200        ;0 - for more speed   
        ;DetectHiddenWindows, On ; The visibility of hidden windows by the script

        CoordMode, Pixel, Window
        CoordMode, Mouse, Window

    ;   Libraries
        ;#Include WinClipAPI.ahk
        ;#Include WinClip.ahk ; http://www.apathysoftworks.com/ahk/index.html & https://autohotkey.com/board/topic/74670-class-winclip-direct-clipboard-manipulations/
        ;#Include JSON.ahk ; https://github.com/cocobelgica/AutoHotkey-JSON
        ;#Include tf.ahk ; https://github.com/hi5/TF
        ;#include includeTest.ahk
        #Include Chrome.ahk-master/Chrome.ahk ;https://github.com/G33kDude/Chrome.ahk

        global ExitString := "initiated"
        global subcounter := 0

    ;   Exiting
        OnExit("OnUnload") ; Run a subroutine or function when exiting the script
    
    OutputDebug, ^^^^^^^^^^^^^ AutoExecute ^^^^^^^^^^^^^

; Variables=====================================================================
    OutputDebug, /////////////////// VARIABLES COMMENCED ///////////////////
    ;FILE VARIABLES
    global ChromeInst 
    global PageInst
    ;WRITE VARIABLES
    global linkingCSV := "fileLocation"

    
    global currentPersonBirthLocation := "INITIALISED"
    global currentPersonDeathLocation := "INITIALISED"
    global currentPersonBirthDate := "INITIALISED"
    global currentPersonDeathDate := "INITIALISED"
    
    ;READ VARIABLES
    global peopleListAddress := "https://www.ancestry.com.au/family-tree/tree/TREEIDLOCATION/listofallpeople?ss=false&usePUBJs=true&pn="
    global treeID
    
    global lastPeopleListPage := False
    global currentPersonNumOnPage := "INITIALISED"

    
    global sizeCurrentPeopleList := "INITIALISED"

    global currentPersonRawText := "INITIALISED"
    global currentPersonName := "INITIALISED"
    global currentPersonFirstName := "INITIALISED"
    global currentPersonSecondName := "INITIALISED"
    global currentPersonRawBirth := "INITIALISED"
    global currentPersonRawDeath := "INITIALISED"
    global currentPersonAncestryID := "INITIALISED"

    OutputDebug, /////////////////// VARIABLES COMPLETED ///////////////////

; ==============================================================================

; Code Start ===================================================================
    OutputDebug, ~~~~~~~~~~~~~~~~~~ CODE START ~~~~~~~~~~~~~~~~~~
    ;Set Starting Conditions
    InputBox, currentPeopleListPage, Mostly Functional Ancestry ID Scraper, "Type a number for starting page. `nIf you enter anything but a number; you break the program & have to start it again.  `nThis is a mostly functional script; not a fancy pants well written progam.  Just type a number.  Probably 1."
    InputBox, treeID, Mostly Functional Ancestry ID Scraper, "paste the Family tree number you want to scrape data from.`nYou should see it in the URL when browsing the tree."
    StrReplace(peopleListAddress, TREEIDLOCATION , treeID)

    createBrowser() ;DONE
    resetCurrentPersonDetails() ;tbc, only tested for initialisation
    
    While, lastPeopleListPage=false {
        updatePeopleListPage(currentPeopleListPage) ;DONE
        findSizeCurrentPeopleList() ;DONE
        currentPersonNumOnPage := 1
        ;zGui(" currentPeopleListPage: " . currentPeopleListPage . "`ncurrentPersonNumOnPage: " currentPersonNumOnPage . " - " . sizeCurrentPeopleList . " :sizeCurrentPeopleList")
        
        While currentPersonNumOnPage <= sizeCurrentPeopleList 
        {
        ;Loop, 5 {
            
            getCurrentPersonDetails() ;DONE
            writeCurrentPersonDetails() ;JUST NEEDS COMMAS AS DELIMITERS WORKED OUT
            currentPersonNumOnPage++
        }
        currentPeopleListPage++
        testLastPeopleListPage()
    }


    ExitString := "~ CODE END ~"
    ExitApp, 0
; ==============================================================================

; Flow functions ===============================================================
    createBrowser(){
        OutputDebug, -------------- createBrowser() started --------------
            FileCreateDir, ChromeProfile
            ChromeInst := new Chrome("ChromeProfile")
        OutputDebug, -------------- createBrowser() finished --------------
    }

    resetCurrentPersonDetails() {
        OutputDebug, -------------- resetCurrentPersonDetails() started --------------
            currentPersonFirstName := "Reset"
            currentPersonSecondName := "Reset"
            currentPersonRawBirth := "Reset"
            currentPersonRawDeath := "Reset"
            currentPersonAncestryID := "Reset"

            currentPersonBirthLocation := "Reset"
            currentPersonDeathLocation := "Reset"
            currentPersonBirthDate := "Reset"
            currentPersonDeathDate := "Reset"
        OutputDebug, -------------- resetCurrentPersonDetails() finished --------------
    }

    updatePeopleListPage(pageNum) {
        OutputDebug, -------------- loadPeopleListPageOne() started --------------
            PageInst := ChromeInst.GetPage()
            PageInst.Call("Page.navigate", {"url": peopleListAddress . pageNum})
            PageInst.WaitForLoad()

        OutputDebug, -------------- loadPeopleListPageOne() finished --------------
    }


   findSizeCurrentPeopleList() {
        OutputDebug, -------------- findSizeCurrentPeopleList() started --------------
            peopleOnPageObj = document.getElementsByClassName("midCol")[0].innerHTML
            peopleOnPageText := chrome.jxon_Dump(PageInst.Evaluate(peopleOnPageObj))
            ;SAMPLE Output{"type":"string","value":"1\u2013100 of&nbsp;1289"}

            personIndexLowStringStart := 27
            personIndexLowStringLength := InStr(peopleOnPageText, "u2013") - 1 - personIndexLowStringStart
            personIndexHighStringStart := InStr(peopleOnPageText, "u2013") + 5
            personIndexHighStringLength := InStr(peopleOnPageText, " of") - personIndexHighStringStart
            
            personIndexLow := SubStr(peopleOnPageText, personIndexLowStringStart, personIndexLowStringLength) - 1
            personIndexHigh := SubStr(peopleOnPageText, personIndexHighStringStart, personIndexHighStringLength)
            sizeCurrentPeopleList := personIndexHigh - personIndexLow
            ;zGui("personIndexLow:" . personIndexLow . ", personIndexHigh:" . personIndexHigh . " - Number = " . sizeCurrentPeopleList)
            
        OutputDebug, -------------- findSizeCurrentPeopleList() finished --------------
    }

    getCurrentPersonDetails() {
        OutputDebug, -------------- getCurrentPersonDetails() started --------------
            ;Name 
                currentPersonObj = document.querySelectorAll(".table480 .colB")[%currentPersonNumOnPage%].innerText
                currentPersonRawText := chrome.jxon_Dump(PageInst.Evaluate(currentPersonObj))
                currentPersonName := StrReplace(currentPersonRawText, "\u00A0", " ")
                currentPersonName := SubStr(currentPersonName, 27)
                currentPersonName := trim(SubStr(currentPersonName, 1, StrLen(currentPersonName)-2))

            ;AncestryID
                currentPersonObj = document.querySelectorAll(".table480 .colB")[%currentPersonNumOnPage%].innerHTML
                currentPersonRawText := chrome.jxon_Dump(PageInst.Evaluate(currentPersonObj))
                
                ;Clipboard := currentPersonRawText
                ;zGui("currentPersonRawText: " . currentPersonRawText)

                ;6\/person\/302119854180\">Chadwick,&nbsp;John&nbsp;<\/a>\n\t\t<\/div>\n\t\t\n\t"}
                ancestryIDStringStart := 
                tempPersonAncestryID := SubStr(currentPersonRawText, 144)
                currentPersonAncestryID := ""
                ;zGui("PRE tempPersonAncestryID=" tempPersonAncestryID)
                Loop, Parse, tempPersonAncestryID 
                {
                    If (A_LoopField = Chr(34))
                    {
                        Break                    
                    }
                    currentPersonAncestryID := currentPersonAncestryID . A_LoopField
                    ;zGui("LOOP currentPersonAncestryID=" . currentPersonAncestryID . " A_LoopField: " . A_LoopField)

                }
                ;zGui("POST currentPersonAncestryID=" currentPersonAncestryID)

            ;Birth
                currentPersonObj = document.querySelectorAll(".table480 .colC")[%currentPersonNumOnPage%].innerText
                currentPersonRawText := chrome.jxon_Dump(PageInst.Evaluate(currentPersonObj))
                ;Clipboard := currentPersonRawText
                
                currentPersonRawBirth := SubStr(currentPersonRawText, 27)
                currentPersonRawBirth := SubStr(currentPersonRawBirth, 1, StrLen(currentPersonRawBirth)-2)
                currentPersonRawBirth := StrReplace(currentPersonRawBirth, "\/", "/")
            ;Death
                currentPersonObj = document.querySelectorAll(".table480 .colD")[%currentPersonNumOnPage%].innerText
                currentPersonRawText := chrome.jxon_Dump(PageInst.Evaluate(currentPersonObj))
                currentPersonRawDeath := SubStr(currentPersonRawText, 27)
                currentPersonRawDeath := SubStr(currentPersonRawDeath, 1, StrLen(currentPersonRawDeath)-2)
                currentPersonRawDeath := StrReplace(currentPersonRawDeath, "\/", "/")

                ;zGui("currentPersonName: " . currentPersonName . "`nAncestryID: " . currentPersonAncestryID . "`ncurrentPersonRawBirth" . currentPersonRawBirth . "`ncurrentPersonRawDeath" . currentPersonRawDeath)
            ;Clipboard := currentPersonRawText
        OutputDebug, -------------- getCurrentPersonDetails() finished --------------
    }

    writeCurrentPersonDetails() {
        OutputDebug, -------------- writeCurrentPersonDetails() started --------------
            clipOff := "\/person\/"
            rawID := currentPersonAncestryID
            If (SubStr(currentPersonAncestryID, 1, StrLen(clipOff)) = clipOff){
                currentPersonAncestryID := SubStr(currentPersonAncestryID, StrLen(clipOff) + 1, StrLen(currentPersonAncestryID)-StrLen(clipOff)-1)
                csvString := Chr(34) . currentPersonName . Chr(34) . "," . Chr(34) . currentPersonRawBirth . Chr(34) . "," . Chr(34) . currentPersonRawDeath . Chr(34) . "," . Chr(34) . currentPersonAncestryID . Chr(34) . "`r"
                ;zGui(rawID . " - " . currentPersonAncestryID)
            } else {
                csvString := Chr(34) . currentPersonName . Chr(34) . "," . Chr(34) . currentPersonRawBirth . Chr(34) . "," . Chr(34) . currentPersonRawDeath . Chr(34) . "," FALSE "`r"
            }
            
            ;zGui(csvString)
            FileAppend, %csvString%, C:\AHK\ancestryScrape.csv
        OutputDebug, -------------- writeCurrentPersonDetails() finished --------------
    }

   testLastPeopleListPage() {
        OutputDebug, -------------- testLastPeopleListPage() started --------------
            nextArrowObj = document.getElementsByClassName("pagingNext")[0].className
            nextArrowClassList := chrome.jxon_Dump(PageInst.Evaluate(nextArrowObj))
            ;page 1 {"type":"string","value":"pagingNext ancBtn silver sml icon iconArrowRight"}
            ; last page {"type":"string","value":"pagingNext ancBtn silver sml icon iconArrowRight disabled"}
            If (InStr(nextArrowClassList, "disabled")>0){
                    ;zGui(nextArrowClassList . "`nFinal Page, " . InStr(nextArrowClassList, "disabled"))
                    lastPeopleListPage := True
                } else {
                    ;zGui(nextArrowClassList . "`nNot Final Page" . InStr(nextArrowClassList, "disabled"))
                }
        OutputDebug, -------------- testLastPeopleListPage() finished --------------
    }


    blankFunction() {
        OutputDebug, -------------- () started --------------

        OutputDebug, -------------- () finished --------------
    }


; ==============================================================================


; ==============================================================================

; Labels =======================================================================

; ==============================================================================

; Common Functions =============================================================

    zGui(consoleString) {
        OutputDebug, -------------- zGui(consoleString) started --------------
        MsgBox, 1, zGui, % consoleString
        IfMsgBox, Cancel 
            ExitApp
        OutputDebug, -------------- zGui(consoleString) finished --------------
        return
    }



    ; NotUsed --- GuiSize(GuiHwnd, EventInfo, Width, Height) {IfEqual, ErrorLevel, 1, return ; Window minimized}MenuHandler(ItemName, ItemPos, MenuName) {MsgBox, 0x40, MenuHandler, % "Item Name: " ItemName "`n". "Item Position: " ItemPos "`n". "Menu Name: " MenuName}
; ==============================================================================

; Close Function================================================================
    OnUnload(ExitReason, ExitCode) {
        Global ; Assume-global mode

        OutputDebug -----------------  EXIT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        zGui("ExitCode:" ExitCode "`nA_ExitReason:"  A_ExitReason "`nExitString:`n" ExitString)
    }
