
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Reset your password</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>

        <div style="width: 25vw; height: 50vh" class="container bg-body-secondary mt-5 mb-5">
            <h2>Forgot password</h2>
            <form action="resetpassword" method="post">
                <input type="hidden" name="email" value="${param.email}"/>
                <input type="hidden" name="token" value="${param.token}"/>
                <div class="form-group ">
                    <label for="newpassword">New Password:</label>
                    <div class="password-container">
                        <input id="newpass" type="password" name="newpassword"  class="form-control"  placeholder="Enter new password" required>
                    </div>
                </div>
                <br>
                <div class="form-group ">
                    <label for="renewpassword">New Password (again):</label>
                    <div class="password-container">
                        <input id="renewpass" required type="password" name="renewpassword" oninput="checkPassword()" class="form-control" placeholder="Enter new password again"/>
                    </div>
                    <p class="text-danger" id ="newpassmsg"></p>
                </div>
                <br>
                <div class="d-flex justify-content-center p-2 mt-5">
                    <input  id="resetBtn"  type="submit" class="btn btn-primary" value="Reset password"/>
                </div>
                <br>
            </form>
        </div>


        <%@include file="../components/footer.jsp" %>
        <script>
            function checkPassword() {
                var password1 = document.getElementById("newpass");
                var password2 = document.getElementById("renewpass");
                if (password1.value === password2.value) {
                    document.getElementById("newpassmsg").innerHTML = '';
                    document.getElementById('resetBtn').disabled = false;

                } else {
                    document.getElementById("newpassmsg").innerHTML = 'Password does not match.';
                    document.getElementById('resetBtn').disabled = true;
                }
            }
        </script>
    </body>
</html>
