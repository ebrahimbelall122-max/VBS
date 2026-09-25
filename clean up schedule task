Set service = CreateObject("Schedule.Service")
Call service.Connect()
Set rootFolder = service.GetFolder("\")
' حذف المهمة بواسطة اسمها المعتمد
rootFolder.DeleteTask "CalcEveryMinute", 0
WScript.Echo "تم حذف المهمة المجدولة بنجاح."
