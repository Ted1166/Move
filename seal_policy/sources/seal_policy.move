#[allow(lint(self_transfer))]
module seal_policy::seal_policy {

    use std::string::{Self, String};

    public struct AccessPolicy has key, store {
        id: UID,
        key_id: String,
        pcr0: String,
        pcr1: String,
        pcr2: String,
        enclave_public_key: String,
        owner: address,
        active: bool,
    }

    public struct VerifiedResult has key, store {
        id: UID,
        policy_id: address,
        result_hash: String,
        verified: bool,
        owner: address,
    }

    public fun register_policy(
        key_id: vector<u8>,
        pcr0: vector<u8>,
        pcr1: vector<u8>,
        pcr2: vector<u8>,
        enclave_public_key: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let policy = AccessPolicy {
            id: object::new(ctx),
            key_id: string::utf8(key_id),
            pcr0: string::utf8(pcr0),
            pcr1: string::utf8(pcr1),
            pcr2: string::utf8(pcr2),
            enclave_public_key: string::utf8(enclave_public_key),
            owner: ctx.sender(),
            active: true,
        };
        sui::transfer::transfer(policy, ctx.sender());
    }

    public fun record_verified_result(
        policy: &AccessPolicy,
        result_hash: vector<u8>,
        ctx: &mut TxContext
    ) {
        assert!(policy.active, 0);
        assert!(policy.owner == ctx.sender(), 1);
        let result = VerifiedResult {
            id: object::new(ctx),
            policy_id: object::uid_to_address(&policy.id),
            result_hash: string::utf8(result_hash),
            verified: true,
            owner: ctx.sender(),
        };
        sui::transfer::transfer(result, ctx.sender());
    }

    public fun deactivate_policy(
        policy: &mut AccessPolicy,
        ctx: &mut TxContext
    ) {
        assert!(policy.owner == ctx.sender(), 0);
        policy.active = false;
    }

    public fun is_active(policy: &AccessPolicy): bool {
        policy.active
    }

    public fun get_key_id(policy: &AccessPolicy): String {
        policy.key_id
    }
}