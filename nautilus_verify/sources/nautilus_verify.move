#[allow(lint(self_transfer))]
module nautilus_verify::nautilus_verify {
    use std::string::{Self, String};

    public struct RegisteredEnclave has key, store {
        id: UID,
        pcr0: String,
        pcr1: String,
        pcr2: String,
        enclave_public_key: String,
        owner: address,
        active: bool,
    }

    public struct VerifiedComputeResult has key, store {
        id: UID,
        enclave_id: address,
        payload: String,
        signature: String,
        timestamp: u64,
        accepted: bool,
        owner: address,
    }

    public fun register_enclave(
        pcr0: vector<u8>,
        pcr1: vector<u8>,
        pcr2: vector<u8>,
        enclave_public_key: vector<u8>,
        ctx: &mut TxContext
    ) {
        let enclave = RegisteredEnclave {
            id: object::new(ctx),
            pcr0: string::utf8(pcr0),
            pcr1: string::utf8(pcr1),
            pcr2: string::utf8(pcr2),
            enclave_public_key: string::utf8(enclave_public_key),
            owner: ctx.sender(),
            active: true,
        };
        sui::transfer::transfer(enclave, ctx.sender());
    }

    public fun verify_and_record(
        enclave: &RegisteredEnclave,
        payload: vector<u8>,
        signature: vector<u8>,
        timestamp: u64,
        ctx: &mut TxContext
    ) {
        assert!(enclave.active, 0);
        assert!(enclave.owner == ctx.sender(), 1);
        assert!(timestamp > 0, 2);

        let result = VerifiedComputeResult {
            id: object::new(ctx),
            enclave_id: object::uid_to_address(&enclave.id),
            payload: string::utf8(payload),
            signature: string::utf8(signature),
            timestamp,
            accepted: true,
            owner: ctx.sender(),
        };
        sui::transfer::transfer(result, ctx.sender());
    }

    public fun deactivate_enclave(
        enclave: &mut RegisteredEnclave,
        ctx: &mut TxContext
    ) {
        assert!(enclave.owner == ctx.sender(), 0);
        enclave.active = false;
    }

    public fun is_active(enclave: &RegisteredEnclave): bool {
        enclave.active
    }

    public fun get_enclave_key(enclave: &RegisteredEnclave): String {
        enclave.enclave_public_key
    }
}