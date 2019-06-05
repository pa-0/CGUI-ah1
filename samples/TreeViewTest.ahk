
#MaxHotkeysPerInterval 500
SetBatchlines, -1
global font_size := 20
MyWindow := new CTreeViewTest("Demo") ;Create an instance of this window class
return

^r::
  reload
return

^wheeldown::
  old_font := font_size
  if font_size > 15
    font_size -= 1
  tooltip, %font_size%
  if old_font != font_size
    MyWindow.treeNoteList.Font.Size:=font_size
return
^wheelup::
  old_font := font_size
  if font_size < 40
    font_size += 1
  if old_font != font_size
    MyWindow.treeNoteList.Font.Size:=font_size
return


#include ..\CGUI.ahk
Class CTreeViewTest Extends CGUI
{
    Class treeNoteList {
      static Type    := "TreeView"
      static Options := "x12 y12 w214 h400"
      static Text    := ""
      __New()
      {
          this.LargeIcons := true
          this.DefaultIcon := A_ScriptDir . "\TreeViewTest.Im2.bmp" ;Default Green
          
          item :=  this.Items.add("Hello")
          item.icon := A_ScriptDir . "\TreeViewTest.Img.bmp" ;Icon red
          item.add("World") ;Icon Default
          
          
          item :=  this.Items.add("Hello")
          item.add("World") ;Icon Default
          item.icon := A_ScriptDir . "\TreeViewTest.Img.bmp" ;Icon red
          
          global font_size
          this.Font.size := font_size
      }
    }
    
    
    Size(Event){
      this.treeNoteList.Height := this.windowHeight/1.5 + -60
      this.treeNoteList.Width := this.windowWidth/1.5 - 38
    }
    
    
    ;This constructor is called when the window is instantiated. It's used to setup window properties and also control properties. It's also common that the window shows itself.
    __New(Title)
    {
        ;Set some window properties
        this.Title := Title
        this.Resize := true
        this.MinSize := "200x150"
        this.CloseOnEscape := true
        this.DestroyOnClose := true
        
        ;Show the window
        this.Show("")
        
    }

    ;Called after the window was destroyed
    PostDestroy()
    {
        ;Exit when all instances of this window are closed
        if(!this.Instances.MaxIndex())
            ExitApp
    }
}