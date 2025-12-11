<!doctype html>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="en">
    <head>
        <title>ChangePass</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800,900" rel="stylesheet">


        <link rel="stylesheet" href="css/styles.css">
        
    </head>
    <body>



        <button type="button" class="btn btn-warning" data-toggle="modal" data-target="#profile">
            <img class="icon" style="border: 1px solid black;border-radius: 100%;width: 30px;height: 30px;" src="${sessionScope.info.avatar}" alt="">  
            ${sessionScope.info.username}
        </button>
        <button type="button" class="btn btn-outline-light me-2" data-toggle="modal" data-target="#changepass">
            Change Password
        </button>
        <!-- change password modal -->
        <div class="modal fade" id="changepass" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 style="color: black">Change Password</h4>
                        <button type="button" class="close d-flex align-items-center justify-content-center" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true" class="ion-ios-close"></span>
                        </button>

                    </div>
                    <div class="modal-body p-4 p-md-5">
                        <div class="icon d-flex align-items-center justify-content-center">
                            <span class="ion-ios-person"></span>
                        </div>

                        <form action="changepass" class="login-form" method="post">

                            <div class="form-group mb-3">
                                <input type="password" name="op" class="form-control rounded-left" placeholder="Old pass word">
                            </div>
                            <div class="form-group d-flex mb-3">                             
                                <input type="password" name="p1" class="form-control rounded-left" placeholder="New Password">
                            </div>
                            <div class="form-group d-flex mb-3">  
                                <input type="password" name="p2" class="form-control rounded-left" placeholder="Comfirm Password">
                            </div>
                            <div class="form-group">
                                <button class="btn btn-warning btn-primary fw-bold text-dark-emphasis" type="submit">Confirm</button>
                                <button class="btn btn-outline-dark" type="button" class="close" data-dismiss="modal" aria-label="Close">Cancel</button>
                                <span aria-hidden="true" class="ion-ios-close"></span>
                                </button>
                            </div>
                            <div class="form-group d-md-flex">

                            </div>
                        </form>
                    </div>
                    
                </div>
            </div>
        </div>
        <!-- Profile -->
        <div class="modal fade" id="profile" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 style="color: black">Profile</h4>
                        <button type="button" class="close d-flex align-items-center justify-content-center" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true" class="ion-ios-close">X</span>
                        </button>

                    </div>
                    <div class="modal-body p-4 p-md-5">
                        <div class="icon d-flex align-items-center justify-content-center">
                            <span class="ion-ios-person"></span>
                        </div>

                        <form action="profile" class="login-form" enctype='multipart/form-data' method="post">
                            <c:set value="${sessionScope.info}" var="in"/>
                            <div class="form-group" style="color: black">
                                <img class="icon" id="image" style="border: 1px solid black;border-radius: 100%;width: 50px;height: 50px;" src="${in.avatar}" alt="">

                                <input type="file" accept="image/jpg,image/png" name="avatar" onchange="chooseFile(this)" style="color: white;"/>



                            </div>

                            <div class="form-group" style="text-align: left;color: black">
                                Email:
                                <input type="text" name="email" class="form-control rounded-left" readonly="" value="${in.email}"/>
                            </div>
                            <div class="form-group" style="text-align: left;color: black">
                                Name
                                <input type="text" name="name" class="form-control rounded-left" value="${in.username}">
                            </div>
                            <div class="form-group" style="text-align: left;color: black">
                                Age
                                <input type="text" name="age" class="form-control rounded-left" value="${in.age}">
                            </div>
                            <div class="form-group row" style="text-align: left;color: black">
                                <div class="col-12">Gender</div>
                                <div class="col-3 ms-4">
                                    <input class="me-2 form-check-input" name="gen"  type="radio"  value="1" ${in.gender? "checked" : "" } />Male
                                </div>
                                <div class="col-3">
                                    <input class="me-2 form-check-input" name="gen"  type="radio" value="0" ${in.gender? "" : "checked" } />Female
                                </div>
                            </div>
                            <div class="form-group" style="text-align: left;color: black">
                                Mobile
                                <input type="text" name="mo" class="form-control rounded-left" value="0${in.mobile}">
                            </div>
                            <div class="form-group" style="text-align: left;color: black">
                                Address
                                <input type="text" name="add" class="form-control rounded-left" value="${in.address}">
                            </div>


                            <div class="form-group mt-4">
                                <button class="btn btn-warning btn-primary fw-bold text-dark-emphasis" type="submit">Confirm</button>
                                <button type="button" class="close btn btn-outline-dark" data-dismiss="modal" aria-label="Close">Cancel</button>
                                <span aria-hidden="true" class="ion-ios-close"></span>
                            </div>
                            <div class="form-group d-md-flex">

                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>

        <script src="js/jquery.min.js"></script>
        <script src="js/popper.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <script src="js/main.js"></script>
        <script>
                                        function  chooseFile(input) {
                                            if (input.files && input.files[0]) {
                                                var reader = new FileReader();

                                                reader.onload = function (e) {
                                                    $('#image').attr('src', e.target.result);
                                                }
                                                reader.readAsDataURL(input.files[0]);
                                            }
                                        }

        </script>
    </body>
</html>