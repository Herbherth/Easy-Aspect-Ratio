# Easy-Aspect-Ratio
Only works for 4.2 godot version (and hopefully newer version too). Older versions does not have a signal for project settings changes and will not work as it is.

![Image showing how the aspect ratio looks like](Images/addonScreenShot.png)

This addon adds a new option to the bottom panel named "Aspect Ratio", where you can easily change between many aspects to see how your game looks on different types of screen without worrying about getting the right absolute pixel values.

Just type width or height you wish and the closest values with the ratio select will be set. If you want to, you can also find the closest options rounded up the value you submitted.

![If you choose an value bigger than your screen resolution, an error is shown, but you can still use this setting](Images/ErrorImage.png)

If you choose some value that is bigger than your screen resolution, an error is shown, but you can still use this values.

This also brings some useful window settings to an easier location. There is no need to go to "Project Settings > Window >..." and scroll through a lot of options just to test your game on fullscreen or keep it always on top.

![Common aspect ratios options organized by Portrait and Landscape](Images/aspetrationsOptionsList.png)

It comes with the most common aspect ratios out there, but feel free to add more or delete those if needed.

![Add new aspect ratio popup window. You can choose the name, width ratio and height ratio](Images/newRatioWindow.png)

If you change the window size through project settings, the aspect ratio addon will update to "Custom" aspect since it does not know what aspect you are working with. You can always set back an aspect through the addon though.
