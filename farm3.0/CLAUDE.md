# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a decentralized blockchain farming game built for Monad, implementing an on-chain farm ecosystem with NFTs, ERC-20 tokens, and oracle integration. The project follows a contract-first architecture with only smart contracts and frontend (no backend).

## Architecture

**MVP Implementation Structure:**
- **Smart Contracts (Solidity + Foundry)**: Core game logic, asset management, and state handling
- **Frontend (React + Web3)**: UI, user interactions, and direct contract calls
- **No Backend**: Frontend handles data aggregation and state queries

**Core Modules:**
- `SeedNFT`: ERC-721 seeds/crops with dynamic lifecycle (Seed → Growing → Mature)
- `LandNFT`: ERC-721 land parcels with state machine (Idle → Growing → Ripe → LockedIdle)  
- `KindnessToken` (KIND): ERC-20 for helping others (watering/fertilizing)
- `Shop`: Contract for purchasing seeds with native tokens or KIND
- `FarmGame`: Main game contract orchestrating interactions
- Weather system using Gelato VRF for randomness

## Game Mechanics

**Core Loop:** Land claiming → Planting → Growth → Harvest/Steal → Cooldown → Reclaim

**Assets:**
- **Seeds/Crops**: Common (wheat 60min, corn 90min, pumpkin 120min) bought with native tokens; Rare (strawberry 75min, grape 100min, watermelon 110min) bought with KIND
- **Shop System**: Players purchase seeds from shop contract before planting
- **Land States**: Idle/Growing/Ripe/Stealing/LockedIdle with 5min cooldown
- **Weather Effects**: Per-land independent weather affecting growth (sunny/rainy +20%/storm pause 5min/cloudy -10%)
- **Boosters**: Watering (-2min), Fertilizing (-5%), max 10 per crop

**Lazy Evaluation**: Weather and growth calculated only during player interactions to optimize gas usage

## Development Setup

Since no configuration files exist yet, contracts will likely use:
- **Foundry** for contract development, testing, and deployment
- **Forge** for testing and gas optimization  
- **Cast** for contract interactions

Frontend will integrate using contract ABIs and deployment addresses after contracts are complete.

## Key Implementation Notes

- Weather randomness uses Gelato VRF with 15-minute segments
- Growth progress uses lazy evaluation with accumulated time tracking
- KIND tokens earned by helping others (15 daily limit)
- Dual ranking system: crop count + KIND holdings
- All game state stored on-chain with minimal off-chain dependencies