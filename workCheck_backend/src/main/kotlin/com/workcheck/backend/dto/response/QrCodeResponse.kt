package com.workcheck.backend.dto.response

// 근무지 QR 코드 응답
data class QrCodeResponse(
    val workplaceId: Long,
    val qrCode: String
)
