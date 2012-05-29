<?php
// Recipient
$to  = 'mailcatcher@test.com';

// Subject
$subject = 'Test Email';

// Message
$message = '
<html>
<head>
  <title>Hello, World</title>
</head>
<body>
  <p>This is test.</p>
</body>
</html>
';

// To send HTML mail, the Content-type header must be set
$headers  = 'MIME-Version: 1.0' . "\r\n";
$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";

// Additional headers
$headers .= 'To: Mailcatcher <mailcatcher@test.com>' . "\r\n";
$headers .= 'From: Vagrant <vagrant@test.com>' . "\r\n";

// Mail it
$result = mail($to, $subject, $message, $headers);
