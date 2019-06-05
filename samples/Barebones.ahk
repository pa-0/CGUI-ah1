#SingleInstance,Force
#include ..\CGUI.ahk

new MyGui("Cool GUI")
return

Class MyGui Extends CGUI {
  ;Controls can be defined as class variables at the top of the class like this:
  btnButton := this.AddControl("Button", "myButton", "", "button")
  
  __New(Title){
    this.Title := Title
    this.CloseOnEscape := true
    this.DestroyOnClose := true
    
    ;Show the window
    this.Show("w250 h100")
  }
  
  myButton_click(){
      msgbox Hello world!
  }
}