# EV Charging Network Management – Business Requirements

## Language / ภาษา

- **Document language**: Thai (ภาษาไทย)
- **Spec / Design / Tasks**: Thai
- **Code & comments**: English

## Background

ประเทศไทยมีจำนวนรถยนต์ไฟฟ้า (EV) เพิ่มขึ้นอย่างรวดเร็ว แต่โครงข่ายสถานีชาร์จยังไม่เพียงพอและขาดระบบบริหารจัดการที่มีประสิทธิภาพ บริษัทผู้ให้บริการสถานีชาร์จ EV ต้องการระบบจัดการเครือข่ายสถานีชาร์จหลายจุดทั่ว กทม. และปริมณฑล ที่สามารถ monitor สถานะแบบ real-time, รองรับการจอง, คิดราคาแบบ dynamic, และ optimize การใช้งานทั้งเครือข่าย

## Problem Statement

- ผู้ใช้ EV ไม่รู้ว่าสถานีชาร์จไหนว่าง ต้องขับไปดูเอง เสียเวลาและพลังงาน
- สถานีชาร์จบางจุดแน่นมาก ในขณะที่บางจุดว่างตลอด — ใช้งานไม่ทั่วถึง
- ไม่มีระบบจอง ทำให้ไม่แน่ใจว่าขับไปถึงแล้วจะว่างหรือไม่
- การคิดราคาแบบ flat rate ไม่ส่งเสริมให้กระจาย demand (peak congestion)
- ผู้ดำเนินการไม่มี visibility ว่าสถานีไหนมีปัญหา (เครื่องเสีย, ชาร์จช้า)
- ไม่มีข้อมูลสำหรับวางแผนขยายสถานีใหม่

## Goals

1. สร้างระบบบริหารจัดการเครือข่ายสถานีชาร์จ EV แบบ real-time
2. ให้ผู้ใช้ค้นหาสถานีว่าง & จองล่วงหน้าได้
3. ใช้ dynamic pricing เพื่อกระจาย demand และเพิ่มรายได้
4. Monitor สุขภาพสถานีชาร์จ & แจ้งเตือนเมื่อมีปัญหา
5. วิเคราะห์ข้อมูลเพื่อวางแผนขยายเครือข่าย
6. รองรับการ load balance กับกริดไฟฟ้า (smart grid ready)

## Scope

### In Scope

- **Station Network Monitoring** – ติดตามสถานะสถานีชาร์จทั้งเครือข่าย real-time
- **User App (Web)** – ค้นหาสถานี (map-based), ดูสถานะ, จอง, เริ่ม/หยุดชาร์จ, ชำระเงิน
- **Booking System** – จอง time slot ล่วงหน้า, grace period, auto-cancel, waitlist
- **Dynamic Pricing** – ราคาตาม peak/off-peak, demand surge, grid signal, subscription plans
- **Payment** – คิดตาม kWh หรือเวลา, PromptPay/Card/Wallet, corporate billing
- **Smart Grid Integration** – load balancing ช่วง peak grid demand, V2G ready
- **Operator Dashboard** – network overview, health monitoring, revenue analytics, demand forecasting

### Out of Scope

- การติดตั้ง hardware สถานีชาร์จจริง
- Mobile native app (ใช้ responsive web / PWA)
- Integration กับระบบรถยนต์ (in-car system)
- Home charging management
- การขาย/ติดตั้งสถานีชาร์จให้บุคคลทั่วไป

## Key Assumptions

1. สถานีชาร์จสื่อสารผ่าน OCPP (Open Charge Point Protocol)
2. เครือข่ายเริ่มต้นมี 50-100 สถานี ในเขต กทม. และปริมณฑล
3. แต่ละสถานีมี 2-10 หัวชาร์จ (AC และ DC)
4. ผู้ใช้ส่วนใหญ่ชาร์จที่ห้าง, ปั๊มน้ำมัน, อาคารสำนักงาน, คอนโด
5. Peak demand: เช้า (08-10), เย็น (17-20), กลางวัน (11-14 ที่ห้าง)
6. ราคาไฟฐานอ้างอิงจากอัตรา TOU ของ กฟน./กฟภ.
7. Data simulation สำหรับ development (จำลอง OCPP messages)

## Functional Requirements

### FR-01: Station & Charger Management
- ลงทะเบียนสถานีชาร์จ (ชื่อ, ที่ตั้ง, เวลาเปิด-ปิด, สิ่งอำนวยความสะดวก)
- จัดการหัวชาร์จ per station (connector type, กำลังไฟ, สถานะ, pricing tier)
- จัดกลุ่มสถานีตามโซน/เจ้าของ/partner

### FR-02: Real-time Station Discovery (User)
- แผนที่แสดงสถานีชาร์จทั้งหมด พร้อม color-coded status
- Filter & sort (connector type, power level, ราคา, ระยะทาง)
- รายละเอียดสถานี: หัวว่าง, ราคาปัจจุบัน, เวลาคาดว่าจะว่าง, reviews
- แนะนำสถานีตาม % แบตที่เหลือ, เส้นทาง, preference

### FR-03: Booking System
- จองหัวชาร์จล่วงหน้า (สูงสุด 24 ชม., slot 30 นาที - 4 ชม.)
- Grace period (15 นาที), auto-cancel ถ้าไม่มา
- Waitlist เมื่อสถานีเต็ม
- Anti-hoarding: จำกัด active bookings ต่อ user

### FR-04: Charging Session Management
- เริ่มชาร์จ (scan QR / กด Start ในแอป)
- เลือก charging mode (เต็ม 100% / ถึง X% / X นาที / X kWh)
- Real-time monitoring ระหว่างชาร์จ (%, kWh, เวลา, ค่าใช้จ่าย)
- Remote stop, notification เมื่อใกล้เสร็จ
- Idle fee หลังชาร์จเสร็จแล้วไม่ย้ายรถ

### FR-05: Dynamic Pricing Engine
- Base rate ตาม charger type (AC ถูก, DC แพง)
- Dynamic multiplier ตามเวลา (TOU), demand level, grid signal
- Subscription plans (pay-per-use, monthly plans พร้อมส่วนลด)
- Price transparency: แสดงราคาชัดเจนก่อนเริ่มชาร์จ

### FR-06: Payment & Billing
- Payment methods: PromptPay, Credit/Debit card, in-app wallet, corporate billing
- Auto-billing เมื่อชาร์จเสร็จ, idle fee, no-show fee
- Invoice & receipt, refund กรณีเครื่องขัดข้อง

### FR-07: Operator Dashboard & Analytics
- Network overview map พร้อมสถานะ real-time
- Alerts: charger offline, low performance, error
- Analytics: utilization rate, revenue, demand forecast, utilization heatmap
- Recommendation สำหรับสถานที่สถานีใหม่
- User analytics: active users, charging patterns, subscription conversion

## Non-Functional Requirements

- **Performance**: real-time status update < 5s, map load < 3s, รองรับ 100,000+ users
- **Reliability**: uptime > 99.9%, zero loss payment transactions, offline mode สำหรับสถานีชาร์จ
- **Security**: HTTPS/TLS, payment PCI DSS compliant, rate limiting & fraud detection
- **Scalability**: รองรับเพิ่มสถานีจาก 50 เป็น 1,000+ โดยไม่ต้องแก้ architecture
- **Interoperability**: OCPP compliant, roaming ready (OCPI), open API สำหรับ partners
- **Usability**: mobile-first, แผนที่ใช้งานง่าย, ภาษาไทย + English

## Success Metrics

| Metric | Target |
|--------|--------|
| Station uptime | > 99% |
| Average utilization rate | > 40% |
| Booking no-show rate | < 10% |
| Average idle time (post-charge) | < 15 นาที |
| User satisfaction (NPS) | > 40 |
| Registered users (Year 1) | > 50,000 |
| Revenue per charger per day | > 500 บาท |
| Dynamic pricing uplift | +15% revenue vs flat rate |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| EV Owner (ส่วนตัว) | ชาร์จรถ | หาสถานีว่าง, จอง, ชาร์จสะดวก, ราคาดี |
| Fleet Manager | บริหารรถ EV องค์กร | Billing รวม, จัดการ vehicles, cost control |
| Station Operator | ดูแลสถานีชาร์จ | Monitor สุขภาพเครื่อง, maintenance, revenue |
| Network Owner | บริหารเครือข่ายทั้งหมด | Analytics, expansion planning, pricing strategy |
| Property Owner (ห้าง/คอนโด) | ให้บริการชาร์จในพื้นที่ | Utilization report, revenue share |
