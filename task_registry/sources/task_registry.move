#[allow(lint(self_transfer, custom_state_change))]
module task_registry::task_registry {
    use std::string::{Self, String};

    public struct Task has key, store {
        id: UID,
        title: String,
        description: String,
        completed: bool,
        owner: address,
    }

    public fun create_task(
        title: vector<u8>,
        description: vector<u8>,
        ctx: &mut TxContext
    ) {
        let task = Task {
            id: object::new(ctx),
            title: string::utf8(title),
            description: string::utf8(description),
            completed: false,
            owner: tx_context::sender(ctx),
        };
        transfer::transfer(task, ctx.sender());
    }

    public fun complete_task(task: &mut Task, ctx: &mut TxContext) {
        assert!(task.owner == tx_context::sender(ctx), 0);
        task.completed = true;
    }

    public fun transfer_task(task: Task, recipient: address) {
        transfer::transfer(task, recipient);
    }

    public fun delete_task(task: Task, ctx: &mut TxContext) {
        assert!(task.owner == tx_context::sender(ctx), 0);
        let Task {id, title: _, description: _, completed: _, owner: _} = task;
        object::delete(id);
    }

    public fun is_completed(task: &Task): bool{
        task.completed
    }

    public fun get_owner(task: &Task): address {
        task.owner
    }
}