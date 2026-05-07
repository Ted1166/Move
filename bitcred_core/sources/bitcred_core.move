#[allow(lint(self_transfer))]
module bitcred_core::bitcred_core {
    use std::string::{Self, String};
    // use std::address;

    public struct CreditRecord has key, store {
        id: UID,
        owner: address,
        btc_address_hash: String,
        credit_score: u64,
        collateral_ratio_bps: u64,
        walrus_audit_blob_id: String,
        seal_policy_id: String,
        nautilus_result_id: String,
        active: bool,
    }

    public struct BorrowPosition has key, store {
        id: UID,
        owner: address,
        credit_record_id: address,
        collateral_amount: u64,
        borrowed_amount: u64,
        repaid: bool,
    }

    public fun create_credit_record(
        btc_address_hash: vector<u8>,
        credit_score: u64,
        walrus_audit_blob_id: vector<u8>,
        seal_policy_id: vector<u8>,
        nautilus_result_id: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert!(credit_score >= 650 && credit_score <= 850, 0);

        let ratio = score_to_ratio(credit_score);

        let record = CreditRecord {
            id: object::new(ctx),
            owner: ctx.sender(),
            btc_address_hash: string::utf8(btc_address_hash),
            credit_score,
            collateral_ratio_bps: ratio,
            walrus_audit_blob_id: string::utf8(walrus_audit_blob_id),
            seal_policy_id: string::utf8(seal_policy_id),
            nautilus_result_id: string::utf8(nautilus_result_id),
            active: true,
        };
        sui::transfer::transfer(record, ctx.sender());
    }

    public fun open_borrow_position(
        record: &CreditRecord,
        collateral_amount: u64,
        borrow_amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(record.active, 0);
        assert!(record.owner == ctx.sender(), 1);
        assert!(collateral_amount > 0 && borrow_amount > 0, 2);

        let required = (borrow_amount * record.collateral_ratio_bps) / 10000;
        assert!(collateral_amount >= required, 3);

        let position = BorrowPosition {
            id: object::new(ctx),
            owner: ctx.sender(),
            credit_record_id: object::uid_to_address(&record.id),
            collateral_amount,
            borrowed_amount: borrow_amount,
            repaid: false,
        };
        sui::transfer::transfer(position, ctx.sender());
    }

    public fun repay_position(
        position: &mut BorrowPosition, 
        ctx: &mut TxContext,
    ) {
        assert!(position.owner == ctx.sender(), 0);
        assert!(!position.repaid, 1);
        position.repaid = true;
    }

    public fun deactivate_record(
        record: &mut CreditRecord,
        ctx: &mut TxContext
    ) {
        assert!(record.owner == ctx.sender(), 0);
        record.active = false;
    }

    fun score_to_ratio(score: u64): u64 {
        if (score >= 800) { 11000 }
        else if (score >= 750) { 11500 }
        else if (score >= 700) { 12000 }
        else { 13000 }
    }

    public fun get_score(record: &CreditRecord): u64 { record.credit_score }
    public fun get_ratio(record: &CreditRecord): u64 { record.collateral_ratio_bps }
    public fun is_active(record: &CreditRecord): bool { record.active }
}