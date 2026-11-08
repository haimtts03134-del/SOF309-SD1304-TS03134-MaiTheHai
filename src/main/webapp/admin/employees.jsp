<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung -->
<jsp:include page="common/header.jsp" />

<div class="container-fluid px-0">
    <div class="row mb-4 align-items-center">
        <div class="col-md-8">
            <h2 class="fw-bold text-dark"><i class="bi bi-people-fill text-warning me-2"></i>Quản Lý Nhân Viên</h2>
            <p class="text-muted mb-0">Xem danh sách nhân sự, phân quyền vai trò, cập nhật thông tin ảnh đại diện và trạng thái hoạt động.</p>
        </div>
        <div class="col-md-4 text-md-end mt-3 mt-md-0">
            <a href="${pageContext.request.contextPath}/admin/attendance" class="btn btn-warning fw-semibold shadow-sm text-dark">
                <i class="bi bi-calendar-check-fill me-1"></i> Bảng Chấm Công & Ca Làm
            </a>
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
        <!-- Cột Danh sách nhân viên (Chiếm 8/12 cột trên màn hình lớn) -->
        <div class="col-12 col-lg-8">
            <div class="custom-card">
                <div class="card-title-container">
                    <h5 class="custom-card-title"><i class="bi bi-list-task me-2 text-warning"></i>Danh Sách Nhân Viên</h5>
                    <span class="badge bg-secondary-subtle text-dark border">${employees.size()} thành viên</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table custom-table align-middle">
                        <thead>
                            <tr>
                                <th style="width: 80px;">Hình Ảnh</th>
                                <th>Họ Tên & Email</th>
                                <th>Số Điện Thoại</th>
                                <th>Vai Trò</th>
                                <th class="text-center">Trạng Thái</th>
                                <th class="text-center" style="width: 100px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="emp" items="${employees}">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty emp.hinhAnh}">
                                                <c:set var="empImgUrl" value="${emp.hinhAnh}" />
                                                <c:if test="${!emp.hinhAnh.startsWith('http') && !emp.hinhAnh.startsWith('data:') && !emp.hinhAnh.startsWith('/')}">
                                                    <c:set var="empImgUrl" value="${pageContext.request.contextPath}/admin/images/${emp.hinhAnh}" />
                                                </c:if>
                                                <img src="${empImgUrl}" class="rounded-circle border shadow-sm" 
                                                     style="width: 50px; height: 50px; object-fit: cover;" 
                                                     alt="${emp.hoTen}"
                                                     onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100';">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded-circle border bg-light text-muted d-flex align-items-center justify-content-center shadow-sm" style="width: 50px; height: 50px;">
                                                    <i class="bi bi-person fs-4"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${emp.hoTen}</div>
                                        <div class="text-muted" style="font-size: 0.85rem;">
                                            ${emp.email}
                                        </div>
                                    </td>
                                    <td>
                                        <span class="fw-semibold text-secondary">${not empty emp.soDienThoai ? emp.soDienThoai : 'N/A'}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${emp.role.maVaiTro == 'ADMIN'}">
                                                <span class="badge bg-danger-subtle text-danger border rounded-pill">${emp.role.tenVaiTro}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-info-subtle text-info border rounded-pill">${emp.role.tenVaiTro}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${emp.trangThai == 'HoatDong'}">
                                                <span class="badge-active"><i class="bi bi-check-circle-fill me-1"></i>Hoạt động</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-inactive"><i class="bi bi-lock-fill me-1"></i>Đã khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <!-- Nút sửa nhân viên -->
                                        <a href="${pageContext.request.contextPath}/admin/employees?action=edit&id=${emp.maNguoiDung}" 
                                           class="btn btn-sm btn-outline-warning action-btn" title="Chỉnh sửa">
                                            <i class="bi bi-pencil-square"></i>
                                        </a>
                                        <!-- Nút xóa nhân viên -->
                                        <a href="${pageContext.request.contextPath}/admin/employees?action=delete&id=${emp.maNguoiDung}" 
                                           class="btn btn-sm btn-outline-danger action-btn" title="Xóa"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa nhân viên \'${emp.hoTen}\' này không?');">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty employees}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                        Chưa có tài khoản nhân sự nào trong cơ sở dữ liệu. Hãy thêm mới bên cạnh!
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Cột Form thêm / cập nhật nhân viên -->
        <div class="col-12 col-lg-4">
            <div class="form-card">
                <h5 class="fw-bold mb-4 border-bottom pb-2">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <i class="bi bi-pencil-square text-warning me-2"></i>Cập Nhật Nhân Viên
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-plus-circle-fill text-success me-2"></i>Thêm Nhân Viên Mới
                        </c:otherwise>
                    </c:choose>
                </h5>

                <form action="${pageContext.request.contextPath}/admin/employees" method="post">
                    <!-- Truyền ID và Hành động tương ứng -->
                    <c:choose>
                        <c:when test="${isEdit}">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${selectedEmployee.maNguoiDung}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="insert">
                        </c:otherwise>
                    </c:choose>

                    <!-- Họ và tên -->
                    <div class="mb-3">
                        <label for="hoTen" class="form-label">Họ và tên nhân viên <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="hoTen" name="hoTen" 
                               placeholder="Ví dụ: Nguyễn Văn A" value="${selectedEmployee.hoTen}" required>
                    </div>

                    <!-- Email đăng nhập -->
                    <div class="mb-3">
                        <label for="email" class="form-label">Email đăng nhập <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email" 
                               placeholder="Ví dụ: nva@qrcoffee.com" value="${selectedEmployee.email}" required>
                    </div>

                    <!-- Số điện thoại -->
                    <div class="mb-3">
                        <label for="soDienThoai" class="form-label">Số điện thoại</label>
                        <input type="text" class="form-control" id="soDienThoai" name="soDienThoai" 
                               placeholder="Ví dụ: 0912345678" value="${selectedEmployee.soDienThoai}">
                    </div>

                    <!-- Mật khẩu -->
                    <div class="mb-3">
                        <label for="matKhau" class="form-label">
                            Mật khẩu <c:if test="${!isEdit}"><span class="text-danger">*</span></c:if>
                        </label>
                        <input type="password" class="form-control" id="matKhau" name="matKhau" 
                               placeholder="${isEdit ? 'Để trống nếu không muốn đổi mật khẩu' : 'Nhập mật khẩu tài khoản'}" 
                               <c:if test="${!isEdit}">required</c:if>>
                    </div>

                    <!-- Vai trò người dùng -->
                    <div class="mb-3">
                        <label for="maVaiTro" class="form-label">Vai trò phân quyền <span class="text-danger">*</span></label>
                        <select class="form-select" id="maVaiTro" name="maVaiTro" required>
                            <option value="" disabled ${empty selectedEmployee ? 'selected' : ''}>-- Chọn vai trò --</option>
                            <c:forEach var="role" items="${roles}">
                                <option value="${role.maVaiTro}" ${selectedEmployee.role.maVaiTro == role.maVaiTro ? 'selected' : ''}>
                                    ${role.tenVaiTro}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- CHỈNH SỬA & CHỌN ẢNH ĐẠI DIỆN NHÂN VIÊN -->
                    <div class="mb-3">
                        <label for="hinhAnh" class="form-label fw-semibold">
                            <i class="bi bi-image text-warning me-1"></i>Ảnh đại diện Nhân viên (.JPG, .PNG)
                        </label>

                        <!-- Khung xem trước ảnh đại diện trực tiếp -->
                        <div class="text-center p-2 mb-2 bg-light rounded border">
                            <c:set var="empPreviewSrc" value="https://ui-avatars.com/api/?name=${not empty selectedEmployee ? selectedEmployee.hoTen : 'Staff'}&background=0D6EFD&color=fff" />
                            <c:if test="${not empty selectedEmployee.hinhAnh}">
                                <c:choose>
                                    <c:when test="${selectedEmployee.hinhAnh.startsWith('http') || selectedEmployee.hinhAnh.startsWith('data:') || selectedEmployee.hinhAnh.startsWith('/')}">
                                        <c:set var="empPreviewSrc" value="${selectedEmployee.hinhAnh}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="empPreviewSrc" value="${pageContext.request.contextPath}/admin/images/${selectedEmployee.hinhAnh}" />
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <img id="empImagePreview" src="${empPreviewSrc}" class="rounded-circle border shadow-sm mb-1" 
                                 style="height: 100px; width: 100px; object-fit: cover;" 
                                 alt="Xem trước ảnh đại diện" 
                                 onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=${selectedEmployee.hoTen}&background=0D6EFD&color=fff';">
                            <small class="d-block text-muted" style="font-size: 0.78rem;">Ảnh đại diện nhân viên hiển thị trên hệ thống</small>
                        </div>

                        <!-- 1. Tải ảnh từ máy tính (.jpg, .png, .jpeg) -->
                        <div class="mb-2">
                            <label class="form-label small text-secondary fw-semibold mb-1">
                                <i class="bi bi-upload me-1 text-primary"></i>1. Tải ảnh từ máy tính (.jpg, .png, .jpeg):
                            </label>
                            <input type="file" id="imageFileInput" accept="image/*" class="form-control form-control-sm" onchange="handleFileUpload(this)">
                        </div>

                        <!-- 2. Ô nhập tên file trong thư mục images/ hoặc URL ảnh -->
                        <div class="mb-2">
                            <label class="form-label small text-secondary fw-semibold mb-1">
                                <i class="bi bi-link-45deg me-1 text-primary"></i>2. Hoặc nhập tên file trong images/ hay dán URL:
                            </label>
                            <input type="text" class="form-control form-control-sm" id="hinhAnh" name="hinhAnh" 
                                   placeholder="VD: nv1.jpg, avatar.png hoặc dán link URL" 
                                   value="${selectedEmployee.hinhAnh}" oninput="updateImagePreview(this.value)">
                        </div>
                    </div>

                    <!-- Trạng thái hoạt động -->
                    <div class="mb-3">
                        <label for="trangThai" class="form-label">Trạng thái tài khoản</label>
                        <select class="form-select" id="trangThai" name="trangThai">
                            <option value="HoatDong" ${selectedEmployee.trangThai == 'HoatDong' ? 'selected' : ''}>Hoạt động</option>
                            <option value="Khoa" ${selectedEmployee.trangThai == 'Khoa' ? 'selected' : ''}>Khóa tài khoản</option>
                        </select>
                    </div>

                    <!-- Nút gửi -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-coffee flex-grow-1">
                            <i class="bi bi-cloud-arrow-up-fill me-2"></i>Lưu lại
                        </button>
                        <c:if test="${isEdit}">
                            <a href="${pageContext.request.contextPath}/admin/employees" class="btn btn-outline-secondary">
                                Hủy
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function handleFileUpload(input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = new Image();
                img.onload = function() {
                    const canvas = document.createElement('canvas');
                    let width = img.width;
                    let height = img.height;
                    const maxDim = 600; // Tối đa 600px

                    if (width > maxDim || height > maxDim) {
                        if (width > height) {
                            height = Math.round((height * maxDim) / width);
                            width = maxDim;
                        } else {
                            width = Math.round((width * maxDim) / height);
                            height = maxDim;
                        }
                    }

                    canvas.width = width;
                    canvas.height = height;
                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0, width, height);

                    // Nén ảnh sang DataURL định dạng JPEG 0.85 siêu nhẹ (~30-60KB)
                    const compressedDataUrl = canvas.toDataURL('image/jpeg', 0.85);
                    document.getElementById('hinhAnh').value = compressedDataUrl;
                    updateImagePreview(compressedDataUrl);
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    }

    function updateImagePreview(val) {
        const preview = document.getElementById('empImagePreview');
        if (!preview) return;
        if (!val || val.trim() === '') {
            preview.src = 'https://ui-avatars.com/api/?name=Staff&background=0D6EFD&color=fff';
        } else if (val.startsWith('http') || val.startsWith('data:') || val.startsWith('/')) {
            preview.src = val;
        } else {
            preview.src = '${pageContext.request.contextPath}/admin/images/' + val;
        }
    }
</script>

<!-- Nhúng Footer dùng chung -->
<jsp:include page="common/footer.jsp" />
