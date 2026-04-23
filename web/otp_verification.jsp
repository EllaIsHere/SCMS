<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>OTP Verification | TIP-SC</title>

<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/scms_styles.css">
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Afacad+Flux:wght@100..1000&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

<style>
.otp-container {
    display: flex;
    justify-content: center;
    gap: 8px;
    margin: 20px 0;
}

.otp-input {
    width: 45px;
    height: 45px;
    text-align: center;
    font-size: 20px;
    font-weight: bold;
    border: 2px solid #ddd;
    border-radius: 8px;
}

.otp-input:focus {
    border-color: #007bff;
    outline: none;
}

.warn {
    background-color: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 12px;
    margin: 15px 0;
    border-radius: 4px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.warn i {
    color: #ff9800;
}

.small-text {
    font-size: 13px;
    color: #666;
    margin: 10px 0;
}

.resend-btn {
    background: none;
    border: none;
    color: #007bff;
    cursor: pointer;
    text-decoration: underline;
    font-size: 14px;
}

.resend-btn:hover {
    color: #0056b3;
}
</style>

</head>
<body>

<div class="card">

    <div class="logo">
        <div class="logo-dot"></div>
        <span class="logo-name">TIP-SC</span>
    </div>

    <div style="text-align: center; margin: 20px 0;">
        <i class="fa-solid fa-envelope" style="font-size: 48px; color: #007bff;"></i>
    </div>

    <h1 class="title md" style="text-align: center;">Verify your school email.</h1>
    <p class="sub" style="text-align: center; margin-bottom: 5px;">A 6-digit verification code was sent to</p>
    <p style="text-align: center; font-weight: bold; margin: 5px 0 15px 0;">
        <%= session.getAttribute("otpEmail") %>
    </p>

    <% 
        String error = request.getParameter("error");
        if("expired".equals(error)){
    %>
        <div class="warn">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <span>This code expires in 10 minutes. Do not share it with anyone.</span>
        </div>
    <% } else if("invalid".equals(error)) { %>
        <div class="warn">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <span>Invalid or expired code. Request a new one and try again.</span>
        </div>
    <% } else { %>
        <div class="warn">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <span>This code expires in 10 minutes. Do not share it with anyone.</span>
        </div>
    <% } %>

    <p style="text-align: center; margin-top: 20px; font-weight: bold;">ENTER VERIFICATION CODE:</p>

    <form action="VerifyOTPServlet" method="post" id="otpForm">
        <div class="otp-container">
            <input type="text" class="otp-input" maxlength="1" id="otp1" data-index="1">
            <input type="text" class="otp-input" maxlength="1" id="otp2" data-index="2">
            <input type="text" class="otp-input" maxlength="1" id="otp3" data-index="3">
            <input type="text" class="otp-input" maxlength="1" id="otp4" data-index="4">
            <input type="text" class="otp-input" maxlength="1" id="otp5" data-index="5">
            <input type="text" class="otp-input" maxlength="1" id="otp6" data-index="6">
        </div>
        <input type="hidden" name="otp" id="otpValue">

        <button type="submit" class="btn btn-y" style="width: 100%;">
            VERIFY CODE
        </button>
    </form>

    <div style="text-align: center; margin-top: 15px;">
        <p class="small-text">Didn't receive it?</p>
        <button class="resend-btn" onclick="resendOTP()">Resend code</button>
    </div>

    <p class="small-text" style="text-align: center; margin-top: 10px;">Max 3 resend per hour</p>

</div>

<script>
const otpInputs = document.querySelectorAll('.otp-input');

otpInputs.forEach((input, index) => {
    input.addEventListener('input', (e) => {
        if(e.target.value && index < otpInputs.length - 1) {
            otpInputs[index + 1].focus();
        }
    });

    input.addEventListener('keydown', (e) => {
        if(e.key === 'Backspace' && !e.target.value && index > 0) {
            otpInputs[index - 1].focus();
        }
    });
});

function resendOTP() {
    fetch('VerifyOTPServlet?action=resend')
    .then(response => response.text())
    .then(data => {
        if(data === 'MAX_RESEND') {
            alert('You have reached maximum resend limit (3 per hour)');
        } else if(data === 'RESENT') {
            alert('OTP resent to your email');
        }
    });
}

document.getElementById('otpForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const otp = Array.from(otpInputs).map(inp => inp.value).join('');
    if(otp.length !== 6) {
        alert('Please enter all 6 digits');
        return;
    }
    document.getElementById('otpValue').value = otp;
    document.getElementById('otpForm').submit();
});
</script>

</body>
</html>