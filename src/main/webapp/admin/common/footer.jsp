<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    </div> <!-- Đóng thẻ div #content -->
</div> <!-- Đóng thẻ div #wrapper -->

<!-- Bootstrap 5 JS Bundle (bao gồm Popper) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script Tự động kiểm tra & Thông báo đơn hàng mới (Real-time Order Auto Notifier) -->
<script src="${pageContext.request.contextPath}/common/js/order-auto-notifier.js"></script>

<!-- Script Tự động kiểm tra & Thông báo cập nhật chấm công (Real-time Attendance Auto Notifier) -->
<script src="${pageContext.request.contextPath}/common/js/attendance-auto-notifier.js"></script>

<!-- Script Điều khiển Sidebar và các hiệu ứng động -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const sidebar = document.getElementById('sidebar');
        const content = document.getElementById('content');
        const collapseBtn = document.getElementById('sidebarCollapse');
        
        if (collapseBtn) {
            collapseBtn.addEventListener('click', function () {
                sidebar.classList.toggle('active');
                content.classList.toggle('active');
            });
        }
    });
</script>
</body>
</html>
