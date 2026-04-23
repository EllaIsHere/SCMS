<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Already Registered | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

</head>
<body>

<div class="card">

    <a href="login.jsp" class="back">
        <i class="fa-solid fa-arrow-left"></i> Back to Sign In
    </a>

    <div style="text-align: center; margin: 30px 0;">
        <i class="fa-solid fa-circle-check" style="font-size: 60px; color: #28a745;"></i>
    </div>

    <h1 class="title md" style="text-align: center;">Account already registered.</h1>
    <p class="sub" style="text-align: center;">This email address is already associated with an account.</p>
    <p style="text-align: center; color: #666; margin: 15px 0;">
        You can proceed to sign in with your credentials or reset your password if needed.
    </p>

    <a href="login.jsp" class="btn btn-y" style="display: block; text-align: center; text-decoration: none;">
        SIGN IN
    </a>

</div>

</body>
</html>