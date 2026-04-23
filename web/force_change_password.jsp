<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Change Password | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>
</head>
<body>

<h2>Change Password</h2>

<form action="ChangePasswordServlet" method="post">
    <input type="hidden" name="email" value="<%= request.getParameter("email") %>">

    New Password: <input type="password" name="new_password" required><br><br>
    Confirm Password: <input type="password" name="confirm_password" required><br><br>

    <button type="submit">Change Password</button>
</form>

</body>
</html>