// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract LaborExchange {
    enum TaskStatus {
        Pending,
        Started,
        Finished,
        PendingEmployerAnswer,
        PendingModeratorAnswer,
        Disputed
    }

    struct Task {
        string description;
        uint256 price;
        address employer;
        address worker;
        TaskStatus status;
        Dispute dispute;
    }

    struct Dispute {
        address moderator;
        string employerMsg;
        string workerMsg;
        string decree;
    }

    address public owner;
    address public moderator;

    mapping(uint256 => Task) public tasks;
    uint256 public taskCount;

    event TaskCreated(
        uint256 taskId,
        string description,
        uint256 price,
        address employer
    );
    event TaskAssigned(uint256 taskId, address worker);
    event TaskCompleted(uint256 taskId);
    event DisputeRaised(
        uint256 taskId,
        address moderator,
        address employer,
        address worker
    );
    event DisputeResolved(uint256 taskId, string decree);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyModerator() {
        require(
            msg.sender == moderator,
            "Only moderator can call this function"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //all
    function createTask(
        string memory _description,
        uint256 _price
    ) public payable {
        require(msg.value >= _price, "Insufficient funds");

        taskCount++;
        tasks[taskCount] = Task(
            _description,
            _price,
            msg.sender,
            address(0),
            TaskStatus.Pending,
            Dispute(address(0), "", "", "")
        );

        emit TaskCreated(taskCount, _description, _price, msg.sender);
    }

    //all
    function getPendingTasks() public view returns (Task[] memory) {
        uint256 count = 0;

        for (uint256 i = 1; i <= taskCount; i++) {
            if (tasks[i].status == TaskStatus.Pending) {
                count++;
            }
        }

        Task[] memory pendingTasks = new Task[](count);
        uint256 index = 0;

        for (uint256 i = 1; i <= taskCount; i++) {
            if (tasks[i].status == TaskStatus.Pending) {
                pendingTasks[index] = tasks[i];
                index++;
            }
        }

        return pendingTasks;
    }

    //all
    function getUserTasks() public view returns (Task[] memory) {
        uint256 count = 0;

        for (uint256 i = 1; i <= taskCount; i++) {
            if (tasks[i].employer == msg.sender) {
                count++;
            }
        }

        Task[] memory userTasks = new Task[](count);
        uint256 index = 0;

        for (uint256 i = 1; i <= taskCount; i++) {
            if (tasks[i].employer == msg.sender) {
                userTasks[index] = tasks[i];
                index++;
            }
        }

        return userTasks;
    }

    //employer
    function employerDecision(
        uint256 _taskId,
        bool _accept,
        string memory _msg
    ) public {
        require(
            tasks[_taskId].employer == msg.sender,
            "Only employer can make a decision"
        );
        require(
            tasks[_taskId].status == TaskStatus.PendingEmployerAnswer,
            "Task not awaiting employer's decision"
        );

        if (_accept) {
            tasks[_taskId].status = TaskStatus.Finished;
            if (bytes(_msg).length > 0) {
                tasks[_taskId].dispute.employerMsg = _msg;
            }
            address payable workerAddress = payable(tasks[_taskId].worker);
            workerAddress.transfer(tasks[_taskId].price);
        } else {
            tasks[_taskId].status = TaskStatus.Started;
            if (bytes(_msg).length > 0) {
                tasks[_taskId].dispute.employerMsg = _msg;
            }
        }

        emit TaskCompleted(_taskId);
    }

    //worker
    function workerDecision(uint256 _taskId, bool _accept) public {
        require(
            tasks[_taskId].worker == msg.sender,
            "Only assigned worker can make a decision"
        );
        require(
            tasks[_taskId].status == TaskStatus.Disputed,
            "Task not in dispute"
        );

        if (_accept) {
            tasks[_taskId].status = TaskStatus.Started;
            tasks[_taskId].dispute = Dispute(address(0), "", "", "");
        } else {
            tasks[_taskId].status = TaskStatus.PendingModeratorAnswer;
        }

        emit DisputeResolved(_taskId, "Worker's decision");
    }

    //moderator
    function resolveDispute(
        uint256 _taskId,
        string memory _decree,
        address _winner,
        uint256 _workerShare
    ) public onlyModerator {
        require(
            tasks[_taskId].status == TaskStatus.Disputed,
            "Task not in dispute"
        );

        tasks[_taskId].dispute.decree = _decree;

        if (_winner == tasks[_taskId].employer) {
            address payable employerAddress = payable(tasks[_taskId].employer);
            employerAddress.transfer(tasks[_taskId].price);
        } else if (_winner == tasks[_taskId].worker) {
            address payable workerAddress = payable(tasks[_taskId].worker);
            workerAddress.transfer(tasks[_taskId].price);
        } else {
            address payable employerAddress = payable(tasks[_taskId].employer);
            address payable workerAddress = payable(tasks[_taskId].worker);
            uint256 totalAmount = tasks[_taskId].price;
            uint256 workerAmount = (_workerShare * totalAmount) / 100;
            uint256 employerAmount = ((100 - _workerShare) * totalAmount) / 100;

            employerAddress.transfer(employerAmount);
            workerAddress.transfer(workerAmount);
        }

        emit DisputeResolved(_taskId, _decree);
    }

    //worker
    function takeTask(uint256 _taskId) public {
        require(
            tasks[_taskId].status == TaskStatus.Pending,
            "Task not available"
        );
        require(tasks[_taskId].worker == address(0), "Task already taken");
        require(
            tasks[_taskId].employer == msg.sender,
            "You can not take your task"
        );
        tasks[_taskId].worker = msg.sender;
        tasks[_taskId].status = TaskStatus.Started;
        emit TaskAssigned(_taskId, msg.sender);
    }

    //worker
    function completeTask(uint256 _taskId) public {
        require(
            tasks[_taskId].status == TaskStatus.Started,
            "Task not started"
        );
        require(
            tasks[_taskId].worker == msg.sender,
            "Only assigned worker can complete the task"
        );
        tasks[_taskId].status = TaskStatus.PendingEmployerAnswer;
        emit TaskCompleted(_taskId);
    }

    //owner
    function setModerator(address _moderator) public onlyOwner {
        moderator = _moderator;
    }

    //owner
    function removeModerator() public onlyOwner {
        moderator = address(0);
    }
}
