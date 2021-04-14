pragma solidity >=0.4.22 <0.8.0;

import "./SafeMath.sol";
import "./DETF.sol";
import "./Ownable.sol";

contract DETFAllocation is Ownable {
    using SafeMath for *;

    uint256 public teamAllocation;
    uint256 public treasuryAllocation;
    uint256 public IDOAllocation;
    uint256 public liquidityAllocation;
    uint256 public stakingAllocation;
    uint256 public marketingAllocation;

    address public stakingContract;

    uint256[] public teamReleaseSchedule;
    uint public lastTeamReleaseIndex;

    uint256[] public treasuryReleaseSchedule;
    uint public lastTreasuryReleaseIndex;

    DETF dETF;

    constructor(address dETFAddress) {
        teamAllocation = 0;
        IDOAllocation = 10000.mul(10.pow(18));
        liquidityAllocation = 15000.mul(10.pow(18));
        stakingAllocation = 20000.mul(10.pow(18));
        marketingAllocation = 15000.mul(10.pow(18));

        // The initial 8 dETF is to even out the distribution to the treasury. Without it the balance would end at 19,992
        treasuryAllocation = 8.mul(10.pow(18));

        // Generate team release schedule
        for (uint x = 0; x < 5; x++) {
            teamReleaseSchedule.push(block.timestamp + (x * 30 days));
        }

        // Generate treasury release schedule
        for (uint x = 0; x < 12; x++) {
            treasuryReleaseSchedule.push(block.timestamp + (x * 30 days));
        }

        dETF = DETF(dETFAddress);
    }

    // Any withdrawals made by the team will be logged.
    event NewWithdrawal(address authorizer, address recipient, uint256 amount, string reason);

    // Any account deposits will be logged.
    event NewDeposit(address authorizer, string recipient, uint256 amount);

    //  Any time the staking contract is changed, it will be logged so anyone can verify that contract address.
    event NewStakingContract(address authorizer, address oldContract, address newContract);

    // Anyone can add coins to one of the accounts in this contract.
    function deposit(uint256 amount, uint account) public {
        if (account == 1) {
            dETF._burn(msg.sender, amount);
            teamAllocation = teamAllocation.add(amount);
            NewDeposit(msg.sender, "Team Allocation", amount);
        }
        if (account == 2) {
            dETF._burn(msg.sender, amount);
            liquidityAllocation = liquidityAllocation.add(amount);
            NewDeposit(msg.sender, "Liquidity Allocation", amount);
        }
        if (account == 3) {
            dETF._burn(msg.sender, amount);
            stakingAllocation = stakingAllocation.add(amount);
            NewDeposit(msg.sender, "Staking Allocation", amount);
        }
        if (account == 4) {
            dETF._burn(msg.sender, amount);
            marketingAllocation = marketingAllocation.add(amount);
            NewDeposit(msg.sender, "Marketing Allocation", amount);
        }
        if (account == 5) {
            dETF._burn(msg.sender, amount);
            treasuryAllocation = treasuryAllocation.add(amount);
            NewDeposit(msg.sender, "Treasury Allocation", amount);
        }
    }

    function withdrawTeam(address recipient, uint256 amount) public onlyOwner {
        if (lastTeamReleaseIndex < 5) {
            if (block.timestamp > teamReleaseSchedule[lastTeamReleaseIndex]) {

                // Founders will receive 2000 dETF over the first 5 months for a total of 10,000 dETF
                teamAllocation = teamAllocation.add(2000.mul(10.pow(18)));
                lastTeamReleaseIndex = lastTeamReleaseIndex.add(1);
            }
        }
        teamAllocation = teamAllocation.sub(amount);
        dETF._mint(recipient, amount);
        emit NewWithdrawal(msg.sender, recipient, amount, "Team Allocation");
    }

    function withdrawTreasury(address recipient, uint256 amount) public onlyOwner {
        if (lastTreasuryReleaseIndex < 12) {
            if (block.timestamp > treasuryReleaseSchedule[lastTreasuryReleaseIndex]) {

                // The dETF treasury will receive 1,666 dETF over the first year for a total of 20,000 dETF
                treasuryAllocation = treasuryAllocation.add(1666.mul(10.pow(18)));
                lastTreasuryReleaseIndex = lastTreasuryReleaseIndex.add(1);
            }
        }
        treasuryAllocation = treasuryAllocation.sub(amount);
        dETF._mint(recipient, amount);
        emit NewWithdrawal(msg.sender, recipient, amount, "Treasury Allocation");
    }

    function withdrawIDO(address recipient, uint256 amount) public onlyOwner {
        IDOAllocation = IDOAllocation.sub(amount);
        dETF._mint(recipient, amount);
        emit NewWithdrawal(msg.sender, recipient, amount, "IDO Allocation");
    }

    function withdrawLiquidity(address recipient, uint256 amount) public onlyOwner {
        liquidityAllocation = liquidityAllocation.sub(amount);
        dETF._mint(recipient, amount);
        emit NewWithdrawal(msg.sender, recipient, amount, "Liquidity Allocation");
    }

    function withdrawMarketing(address recipient, uint256 amount) public onlyOwner {
        marketingAllocation = marketingAllocation.sub(amount);
        dETF._mint(recipient, amount);
        emit NewWithdrawal(msg.sender, recipient, amount, "Marketing Allocation");
    }

    function withdrawStaking(uint256 amount) public {
        require(stakingContract != address(0));
        dETF._mint(stakingContract, amount);
        emit NewWithdrawal(msg.sender, stakingContract, amount, "Staking Rewards Allocation");
    }

    function changeStakingContract(address newContract) public onlyOwner {
        address oldStakingContract = stakingContract;
        stakingContract = newContract;
        emit NewStakingContract(msg.sender, oldStakingContract, stakingContract);
    }

}
