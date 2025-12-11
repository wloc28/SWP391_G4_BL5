<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Forgot Password</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>

        <div style="width: 25vw; height: 50vh" class="container bg-body-secondary mt-5 mb-5">
            <h2>Forgot password</h2>
            <form action="forgotpassword" method="post">
                <input type="hidden" name="redirect" value="${param.redirect}"/>
                <div class="form-group mt-5">
                    <label class="p-2" for="email">Email:</label>
                    <input type="email" name="email" class="form-control" id="email" placeholder="Enter your email" required>
                </div>
                <br>

                <div class="d-flex justify-content-center p-2 mt-5">
                    <button id="btnSubmit" type="submit" class="btn btn-primary">Reset passowrd</button>
                </div>
                <br>
            </form>
        </div>
        <script>
            function showPassword() {
                var passField = document.getElementById('password');
                var showIcon = document.getElementById('showIcon');
                if (passField.type === 'password') {
                    passField.type = 'text';
                    showIcon.innerHTML = '<path d="M26.73 15.997a2 2 0 01-.088 2.145C23.96 21.998 20.357 24 16 24c-1.165 0-2.276-.143-3.33-.427l1.69-1.69c.53.078 1.077.117 1.64.117 3.682 0 6.682-1.667 9-5-.756-1.304-1.584-2.395-2.484-3.274l1.414-1.412c1.027 1.006 1.962 2.237 2.8 3.683zM23.071 8.93a1 1 0 010 1.414L10.343 23.071a1 1 0 01-1.414-1.414L21.657 8.929a1 1 0 011.414 0zM16 9c.86 0 1.69.09 2.488.27l-1.758 1.757A9.817 9.817 0 0016 11c-3.682 0-6.682 2-9 6 .535.77 1.107 1.45 1.715 2.042L7.3 20.456a15.978 15.978 0 01-1.943-2.314 2 2 0 01-.088-2.145C7.924 11.417 11.55 9 16 9zm.252 10.992l3.74-3.74a4 4 0 01-3.74 3.74zm-.503-7.984l-3.741 3.74a4 4 0 013.741-3.74z"></path>';
                } else {
                    passField.type = 'password';
                    showIcon.innerHTML = '<path d="M16 9c4.45 0 8.076 2.417 10.73 6.997a2 2 0 01-.088 2.145C23.96 21.998 20.357 24 16 24c-4.357 0-7.96-2.002-10.642-5.858a2 2 0 01-.088-2.145C7.924 11.417 11.55 9 16 9zm0 2c-3.682 0-6.682 2-9 6 2.318 3.333 5.318 5 9 5 3.682 0 6.682-1.667 9-5-2.318-4-5.318-6-9-6zm0 1a4 4 0 110 8 4 4 0 010-8zm0 2a2 2 0 100 4 2 2 0 000-4z"></path>';
                }
            }

        </script>
        <%@include file="../components/footer.jsp" %>
    </body>
</html>
