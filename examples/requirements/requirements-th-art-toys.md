# Digital Blind Box Art Toys – Business Requirements

## Language / ภาษา

- **Document language**: Thai (ภาษาไทย)
- **Spec / Design / Tasks**: Thai
- **Code & comments**: English

## Background

ตลาด Art Toys (Designer Toys / Collectible Figures) เติบโตอย่างรวดเร็ว กล่องสุ่ม (Blind Box) เป็นรูปแบบการขายที่ได้รับความนิยมสูงสุดเพราะให้ความตื่นเต้นและสนุก ธุรกิจต้องการสร้างแพลตฟอร์มที่ให้ลูกค้า **ซื้อกล่องสุ่มแบบ digital** ผ่านเว็บ แล้ว **ไปรับ physical figure ที่สาขา** (ร้าน/booth) ใกล้บ้าน

โมเดลนี้รวมข้อดีของทั้งสองโลก:
- **Digital**: ซื้อได้ทุกที่ทุกเวลา ไม่ต้องต่อคิว ประสบการณ์เปิดกล่องสนุก
- **Physical pickup**: ได้สัมผัสของจริง ลดค่าจัดส่ง ลดความเสียหายระหว่างขนส่ง สร้าง foot traffic ให้สาขา

## Problem Statement

- ลูกค้าต้องไปต่อคิวที่ร้านเพื่อซื้อกล่องสุ่ม บางครั้งของหมดก่อนถึงคิว
- การขายออนไลน์แบบจัดส่งมีความเสี่ยงสินค้าเสียหายระหว่างขนส่ง (Art Toys เปราะบาง)
- ค่าจัดส่งสูงเมื่อเทียบกับราคาสินค้า (blind box ~250-400 บาท, ค่าส่ง ~50-80 บาท)
- ลูกค้าไม่ได้ประสบการณ์ "เปิดกล่อง" ที่สนุกเมื่อซื้อออนไลน์แบบเดิม
- ร้านค้าสาขาขาด foot traffic เพราะคนหันไปซื้อออนไลน์
- การจัดการ inventory ระหว่างหลายสาขาไม่มีประสิทธิภาพ

## Goals

1. สร้าง web application สำหรับซื้อกล่องสุ่ม Art Toys แบบ digital พร้อมประสบการณ์เปิดกล่องที่สนุก
2. ระบบ pickup ที่สาขา — ลูกค้าเลือกสาขาที่สะดวก แล้วไปรับ figure ได้ทันที
3. จัดการ inventory แบบ real-time ระหว่างหลายสาขา
4. สร้าง engagement ผ่าน collection system, trading, และ community
5. เพิ่ม foot traffic ให้สาขาผ่าน pickup model
6. รองรับ limited edition drops และ collaboration series

## Scope

### In Scope

- **Digital Blind Box Purchase** – ซื้อกล่องสุ่มออนไลน์ → เปิดกล่องแบบ digital → ได้ voucher ไปรับของจริง
- **Branch Pickup System** – เลือกสาขา, reserve stock, รับสินค้าด้วย QR code
- **Branch & Inventory Management** – จัดการสาขา, stock per branch, stock transfer
- **Digital Collection & Community** – collection book, progress tracking, trade system
- **Sales & Marketing** – limited drops, membership rewards, referral program
- **Payment** – PromptPay, Credit card, in-app wallet
- **Admin & Operations** – จัดการ series/products, สาขา, events, analytics

### Out of Scope

- การจัดส่งสินค้าทางไปรษณีย์/ขนส่ง (เฟสแรกเฉพาะ pickup เท่านั้น)
- Mobile native application (ใช้ responsive web / PWA)
- Secondary market (ซื้อ-ขายมือสอง)
- International operations (เฉพาะประเทศไทย)
- NFT / blockchain

## Key Assumptions

1. สาขามีอยู่แล้วอย่างน้อย 5-10 แห่งในกรุงเทพฯ และปริมณฑล
2. แต่ละสาขามี staff ที่สามารถ scan QR และส่งมอบสินค้าได้
3. กล่องสุ่มราคาเฉลี่ย 250-400 บาท/กล่อง
4. Secret/rare figure มีอัตราการสุ่มต่ำ (เช่น 1-2%)
5. ลูกค้าส่วนใหญ่อยู่ในกรุงเทพฯ และเมืองใหญ่
6. ระบบต้องรองรับ concurrent users สูงในช่วง limited drop (หลายพันคน)

## Functional Requirements

### FR-01: Digital Blind Box Purchase
- แสดง series ที่เปิดขาย พร้อมข้อมูล (artist, จำนวนตัว, probability, ราคา, stock)
- ขั้นตอนการซื้อ: เลือก series → ชำระเงิน → เปิดกล่อง (reveal animation) → ได้ pickup voucher
- Multi-pull option (เช่น 6 กล่อง guaranteed no duplicate, full set)
- Pity system: เพิ่ม probability ถ้าซื้อหลายกล่องแล้วยังไม่ได้ rare/secret

### FR-02: Digital Reveal Experience
- Reveal animation ที่ตื่นเต้น (effect พิเศษตาม rarity)
- แสดง figure ที่ได้ พร้อม share ไป social media ได้
- Pull history ดูย้อนหลังได้

### FR-03: Branch Pickup System
- แสดงสาขาที่มี stock ของตัวที่ได้ พร้อมระยะทาง/แผนที่
- Reserve stock ที่สาขาทันทีเมื่อเลือก
- Pickup voucher (QR code) มี expiry date (เช่น 7 วัน)
- กระบวนการรับ: ลูกค้าแสดง QR → staff scan → ส่งมอบ → ยืนยันทั้งสองฝ่าย
- จัดการกรณี stock หมด (เปลี่ยนสาขา/รอ transfer) และ voucher หมดอายุ (extend/refund)

### FR-04: Branch & Inventory Management
- ข้อมูลสาขา (ที่ตั้ง, เวลาเปิด-ปิด, สถานะ)
- Real-time stock level ต่อ figure ต่อสาขา
- Stock reservation & auto-release เมื่อ voucher หมดอายุ
- Stock transfer ระหว่างสาขา
- Allocation strategy สำหรับ series ใหม่

### FR-05: Digital Collection & Progress
- Collection book แสดง progress ต่อ series (ได้แล้ว vs silhouette)
- Duplicate management & achievement badges
- สถิติการเปิดกล่อง (rarity distribution, ค่าใช้จ่ายรวม)

### FR-06: Trade System
- เสนอแลก figure กับสมาชิกอื่น (voucher swap สำหรับของที่ยังไม่ได้ไปรับ)
- Trade history & rating

### FR-07: Limited Drop & Events
- Drop events: countdown, เวลาจำกัด, จำนวนจำกัด, purchase limit ต่อคน
- Queue system สำหรับ traffic spike
- Early access สำหรับ members ระดับสูง

### FR-08: Payment & Wallet
- PromptPay, Credit/Debit card, TrueMoney Wallet
- In-app wallet (top-up, balance, auto top-up)
- ไม่มีค่าจัดส่ง (pickup model)

### FR-09: User Account & Membership
- Registration (email, social login, phone verification)
- Membership tiers ตามจำนวนกล่องที่ซื้อ (Bronze → Silver → Gold → Platinum)
- สิทธิพิเศษตาม tier: pity rate bonus, early access
- Referral program

### FR-10: Admin & Operations Dashboard
- จัดการ series, figures, rarity, pricing
- จัดการสาขา, stock allocation, staff accounts
- จัดการ drop events
- Analytics: sales, pickup rate, branch performance, user retention, series popularity

## Non-Functional Requirements

- **Performance**: page load < 3s, reveal animation smooth, รองรับ 5,000+ concurrent users ช่วง drop
- **Security**: payment ผ่าน PCI DSS gateway, QR tamper-proof, bot protection สำหรับ drops
- **Scalability**: auto-scaling ช่วง traffic spike, queue-based processing
- **Usability**: mobile-first, UI สนุก playful, ภาษาไทย
- **Reliability**: uptime > 99.9%, zero data loss, inventory accuracy > 99.9%
- **Fairness**: cryptographically secure random, แสดง probability ชัดเจน (ตามกฎหมาย), pity system ถูกต้อง 100%

## Success Metrics

| Metric | Target |
|--------|--------|
| Concurrent users (drop event) | > 5,000 |
| Uptime | > 99.9% |
| Conversion rate (visit → purchase) | > 8% |
| Pickup rate (voucher ที่ถูกใช้) | > 90% |
| Average time to pickup | < 3 วัน |
| Voucher expiry rate | < 5% |
| Repeat purchase rate | > 60% |
| Inventory accuracy | > 99.9% |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| นักสะสม Art Toys | ซื้อกล่องสุ่มประจำ, สะสมครบ series | เปิดกล่องสนุก, สะสมครบง่าย, แลกตัวซ้ำ |
| Casual buyer | ซื้อเล่นๆ / ซื้อเป็นของขวัญ | ง่าย, สนุก, ไม่ต้องรอส่ง |
| ลูกค้าหน้าร้าน | เดิมซื้อที่ร้าน อยากซื้อออนไลน์บ้าง | ซื้อล่วงหน้า, เลือกเวลาไปรับ |
| Branch staff | จัดการ stock & ส่งมอบสินค้า | Scan & verify ง่าย, ดู stock real-time |
| Admin/Owner | บริหารจัดการระบบ | จัดการ series, สาขา, stock, analytics |
