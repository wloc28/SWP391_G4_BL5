
<c:if test="${sessionScope.msg!=null}">
    <div style="
         position: fixed;
         bottom: 0;
         right: 0;
         left: 0;
         z-index: 1000;" class="alert alert-warning alert-dismissible fade show" role="alert">
        <strong>${sessionScope.msg}</strong>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <% 
        
        session.removeAttribute("msg");
    %>
</c:if>
<script>
    var alertList = document.querySelectorAll('.alert');
    alertList.forEach(function (alert) {
        new bootstrap.Alert(alert);
    });
</script>
