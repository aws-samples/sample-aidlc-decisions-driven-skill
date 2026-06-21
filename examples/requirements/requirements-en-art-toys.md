# Digital Blind Box Art Toys – Business Requirements

## Language

- **Document language**: English
- **Spec / Design / Tasks**: English
- **Code & comments**: English

## Background

The Art Toys (Designer Toys / Collectible Figures) market is growing rapidly. Blind boxes are the most popular sales format because they deliver excitement and fun. The business wants to build a platform that lets customers **purchase blind boxes digitally** via web, then **pick up the physical figure at a nearby branch** (store/booth).

This model combines the best of both worlds:
- **Digital**: Buy anytime anywhere, no queuing, fun unboxing experience
- **Physical pickup**: Touch the real product, no shipping cost, no transit damage, drives foot traffic to branches

## Problem Statement

- Customers must queue at physical stores to buy blind boxes; stock often runs out before their turn
- Online sales with shipping risk damage during transit (Art Toys are fragile)
- Shipping cost is high relative to product price (blind box ~$7-12, shipping ~$1.5-2.5)
- Customers miss the fun "unboxing" experience when buying online traditionally
- Branch stores lose foot traffic as people shift to online purchases
- Managing inventory across multiple branches is inefficient

## Goals

1. Build a web application for purchasing Art Toys blind boxes digitally with a fun reveal experience
2. Branch pickup system — customers choose a convenient branch and collect their figure immediately
3. Real-time inventory management across multiple branches
4. Drive engagement through collection system, trading, and community
5. Increase foot traffic to branches via the pickup model
6. Support limited edition drops and collaboration series

## Scope

### In Scope

- **Digital Blind Box Purchase** – Buy blind box online → digital reveal → receive pickup voucher
- **Branch Pickup System** – Choose branch, reserve stock, collect with QR code
- **Branch & Inventory Management** – Manage branches, stock per branch, stock transfers
- **Digital Collection & Community** – Collection book, progress tracking, trade system
- **Sales & Marketing** – Limited drops, membership rewards, referral program
- **Payment** – Credit card, digital wallet, in-app wallet
- **Admin & Operations** – Manage series/products, branches, events, analytics

### Out of Scope

- Home delivery/shipping (first phase is pickup only)
- Mobile native application (responsive web / PWA)
- Secondary market (buy-sell used figures)
- International operations
- NFT / blockchain

## Key Assumptions

1. At least 5-10 branches exist in the metropolitan area
2. Each branch has staff who can scan QR and hand over products
3. Average blind box price is $7-12 per box
4. Secret/rare figures have low pull rates (e.g., 1-2%)
5. Most customers are in the metropolitan area and major cities
6. System must handle high concurrent users during limited drops (thousands)

## Functional Requirements

### FR-01: Digital Blind Box Purchase
- Display available series with details (artist, figure count, probability, price, stock)
- Purchase flow: select series → pay → reveal animation → receive pickup voucher
- Multi-pull option (e.g., 6 boxes guaranteed no duplicate, full set option)
- Pity system: increased probability after multiple pulls without rare/secret

### FR-02: Digital Reveal Experience
- Exciting reveal animation (special effects based on rarity)
- Display the figure received, shareable to social media
- Pull history viewable

### FR-03: Branch Pickup System
- Show branches with stock of the received figure, with distance/map
- Reserve stock at branch immediately upon selection
- Pickup voucher (QR code) with expiry date (e.g., 7 days)
- Pickup process: customer shows QR → staff scans → handover → both confirm
- Handle out-of-stock (change branch/wait for transfer) and expired vouchers (extend/refund)

### FR-04: Branch & Inventory Management
- Branch information (location, hours, status)
- Real-time stock level per figure per branch
- Stock reservation & auto-release on voucher expiry
- Stock transfer between branches
- Allocation strategy for new series

### FR-05: Digital Collection & Progress
- Collection book showing progress per series (collected vs silhouette)
- Duplicate management & achievement badges
- Pull statistics (rarity distribution, total spending)

### FR-06: Trade System
- Propose figure trades with other members (voucher swap for uncollected items)
- Trade history & rating

### FR-07: Limited Drop & Events
- Drop events: countdown, time-limited, quantity-limited, purchase limit per person
- Queue system for traffic spikes
- Early access for higher-tier members

### FR-08: Payment & Wallet
- Credit/Debit card, digital wallet (Apple Pay, Google Pay)
- In-app wallet (top-up, balance, auto top-up)
- No shipping fees (pickup model)

### FR-09: User Account & Membership
- Registration (email, social login, phone verification)
- Membership tiers based on boxes purchased (Bronze → Silver → Gold → Platinum)
- Tier benefits: pity rate bonus, early access
- Referral program

### FR-10: Admin & Operations Dashboard
- Manage series, figures, rarity, pricing
- Manage branches, stock allocation, staff accounts
- Manage drop events
- Analytics: sales, pickup rate, branch performance, user retention, series popularity

## Non-Functional Requirements

- **Performance**: page load < 3s, smooth reveal animation, support 5,000+ concurrent users during drops
- **Security**: payment via PCI DSS gateway, tamper-proof QR, bot protection for drops
- **Scalability**: auto-scaling during traffic spikes, queue-based processing
- **Usability**: mobile-first, fun playful UI
- **Reliability**: uptime > 99.9%, zero data loss, inventory accuracy > 99.9%
- **Fairness**: cryptographically secure random, clearly displayed probabilities (legal compliance), 100% accurate pity system

## Success Metrics

| Metric | Target |
|--------|--------|
| Concurrent users (drop event) | > 5,000 |
| Uptime | > 99.9% |
| Conversion rate (visit → purchase) | > 8% |
| Pickup rate (vouchers redeemed) | > 90% |
| Average time to pickup | < 3 days |
| Voucher expiry rate | < 5% |
| Repeat purchase rate | > 60% |
| Inventory accuracy | > 99.9% |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| Art Toys Collector | Regularly buys blind boxes, completes series | Fun reveals, easy collection completion, trade duplicates |
| Casual Buyer | Buys occasionally / as gifts | Simple, fun, no shipping wait |
| Walk-in Customer | Previously bought at store, wants online option | Buy in advance, choose pickup time |
| Branch Staff | Manages stock & hands over products | Easy scan & verify, real-time stock view |
| Admin/Owner | Manages the platform | Manage series, branches, stock, analytics |
