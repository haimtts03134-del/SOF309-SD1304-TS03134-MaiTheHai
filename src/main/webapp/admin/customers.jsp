<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung -->
<jsp:include page="common/header.jsp" />

<div class="container-fluid px-0">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold text-dark"><i class="bi bi-person-badge-fill text-warning me-2"></i>Quản Lý Khách Hàng</h2>
            <p class="text-muted">Xem danh sách khách hàng, cập nhật điểm tích lũy thành viên, số điện thoại, email và trạng thái hoạt động.</p>
        </div>
    </div>

    <!-- Thông báo lỗi nếu có -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-radius: 12px;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Thất bại!</strong> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Cột Danh sách khách hàng (Chiếm 8/12 cột trên màn hình lớn) -->
        <div class="col-12 col-lg-8">
            <div class="custom-card">
                <div class="card-title-container">
                    <h5 class="custom-card-title"><i class="bi bi-list-task me-2 text-warning"></i>Danh Sách Khách Hàng</h5>
                    <span class="badge bg-secondary-subtle text-dark border">${customers.size()} thành viên</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table custom-table align-middle">
                        <thead>
                            <tr>
                                <th style="width: 60px;">ID</th>
                                <th>Họ Tên & Email</th>
                                <th>Số Điện Thoại</th>
                                <th class="text-center">Điểm Tích Lũy</th>
                                <th class="text-center">Ngày Đăng Ký</th>
                                <th class="text-center">Trạng Thái</th>
                                <th class="text-center" style="width: 100px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cust" items="${customers}">
                                <%
                                    entity.Customer c = (entity.Customer) pageContext.getAttribute("cust");
                                    
                                    // Che giấu số điện thoại an toàn
                                    String maskedPhone = "";
                                    if (c != null && c.getSoDienThoai() != null) {
                                        String phone = c.getSoDienThoai().trim();
                                        int len = phone.length();
                                        if (len > 6) {
                                            maskedPhone = phone.substring(0, 3) + "****" + phone.substring(len - 3);
                                        } else {
                                            maskedPhone = "****";
                                        }
                                    }
                                    pageContext.setAttribute("maskedPhone", maskedPhone);
                                    
                                    // Che giấu họ tên an toàn
                                    String maskedName = "";
                                    if (c != null && c.getHoTen() != null) {
                                        String name = c.getHoTen().trim();
                                        String[] words = name.split("\\s+");
                                        if (words.length > 2) {
                                            maskedName = words[0] + " * " + words[words.length - 1];
                                        } else if (words.length == 2) {
                                            maskedName = words[0] + " *";
                                        } else if (words.length == 1) {
                                            maskedName = words[0];
                                        }
                                    }
                                    pageContext.setAttribute("maskedName", maskedName);
                                %>
                                <tr>
                                    <td>
                                        <span class="fw-bold text-secondary">#${cust.maKhachHang}</span>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${maskedName}</div>
                                        <div class="text-muted" style="font-size: 0.85rem;">
                                            ${not empty cust.email ? cust.email : 'Chưa cập nhật email'}
                                        </div>
                                    </td>
                                    <td>
                                        <span class="fw-semibold text-secondary">${maskedPhone}</span>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-warning text-dark fw-bold rounded-pill" style="font-size: 0.9rem;">
                                            <i class="bi bi-star-fill me-1"></i>${cust.diemTichLuy}
                                        </span>
                                    </td>
                                    <td class="text-center text-muted" style="font-size: 0.85rem;">
                                        <fmt:formatDate value="${cust.ngayDangKy}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${cust.trangThai == 'HoatDong'}">
                                                <span class="badge-active"><i class="bi bi-check-circle-fill me-1"></i>Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-inactive"><i class="bi bi-lock-fill me-1"></i>Ngừng hoạt động</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <!-- Nút sửa khách hàng -->
                                        <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${cust.maKhachHang}" 
                                           class="btn btn-sm btn-outline-warning action-btn" title="Chỉnh sửa">
                                            <i class="bi bi-pencil-square"></i>
                                        </a>
                                        <!-- Nút xóa khách hàng -->
                                        <a href="${pageContext.request.contextPath}/admin/customers?action=delete&id=${cust.maKhachHang}" 
                                           class="btn btn-sm btn-outline-danger action-btn" title="Xóa"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa khách hàng \'${cust.hoTen}\' này không?');">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty customers}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                        Chưa có thông tin khách hàng nào trong cơ sở dữ liệu. Hãy thêm mới bên cạnh!
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Cột Form thêm / cập nhật khách hàng -->
        <div class="col-12 col-lg-4">
            <div class="form-card">
                <h5 class="fw-bold mb-4 border-bottom pb-2">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <i class="bi bi-pencil-square text-warning me-2"></i>Cập Nhật Khách Hàng
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-plus-circle-fill text-success me-2"></i>Thêm Khách Hàng Mới
                        </c:otherwise>
                    </c:choose>
                </h5>

                <form action="${pageContext.request.contextPath}/admin/customers" method="post">
                    <!-- Truyền ID và Hành động tương ứng -->
                    <c:choose>
                        <c:when test="${isEdit}">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${selectedCustomer.maKhachHang}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="insert">
                        </c:otherwise>
                    </c:choose>

                    <!-- Họ và tên -->
                    <div class="mb-3">
                        <label for="hoTen" class="form-label">Họ và tên khách hàng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="hoTen" name="hoTen" 
                               placeholder="Ví dụ: Nguyễn Văn A" value="${selectedCustomer.hoTen}" required>
                    </div>

                    <!-- Số điện thoại -->
                    <div class="mb-3">
                        <label for="soDienThoai" class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="soDienThoai" name="soDienThoai" 
                               placeholder="Ví dụ: 0912345678, 0381234567" value="${selectedCustomer.soDienThoai}" 
                               pattern="(03|05|07|08|09)[0-9]{8}"
                               title="Số điện thoại phải gồm 10 chữ số bắt đầu bằng các đầu số 03, 05, 07, 08 hoặc 09" required>
                    </div>

                    <!-- Email -->
                    <div class="mb-3">
                        <label for="email" class="form-label">Địa chỉ Email</label>
                        <input type="email" class="form-control" id="email" name="email" 
                               placeholder="Ví dụ: nva@gmail.com" value="${selectedCustomer.email}">
                    </div>

                    <!-- Điểm tích lũy -->
                    <div class="mb-3">
                        <label for="diemTichLuy" class="form-label">Điểm tích lũy</label>
                        <input type="number" class="form-control" id="diemTichLuy" name="diemTichLuy" min="0"
                               placeholder="Ví dụ: 10" value="${not empty selectedCustomer ? selectedCustomer.diemTichLuy : '0'}">
                    </div>

                    <!-- Trạng thái tài khoản -->
                    <div class="mb-3">
                        <label for="trangThai" class="form-label">Trạng thái hoạt động</label>
                        <select class="form-select" id="trangThai" name="trangThai">
                            <option value="HoatDong" ${selectedCustomer.trangThai == 'HoatDong' ? 'selected' : ''}>Hoạt động</option>
                            <option value="NgungHoatDong" ${selectedCustomer.trangThai == 'NgungHoatDong' ? 'selected' : ''}>Ngừng hoạt động</option>
                        </select>
                    </div>

                    <!-- Nút gửi -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-coffee flex-grow-1">
                            <i class="bi bi-cloud-arrow-up-fill me-2"></i>Lưu lại
                        </button>
                        <c:if test="${isEdit}">
                            <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-outline-secondary">
                                Hủy
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Nhúng Footer dùng chung -->
<jsp:include page="common/footer.jsp" />
