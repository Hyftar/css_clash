# CssClash

A game where you clash with style!

## Setup

1. Clone the repository:
  ```bash
  git clone https://github.com/yourusername/css_clash.git
  cd css_clash
  ```

2. Create a `.envrc` file with the following content:
  ```env
  use flake nix/.
  ```

3. Create a `.env` file with the following content:
  ```env
  SECRET_KEY_BASE=[random_string]
  DB_USER=postgres
  DB_PASSWORD=postgres
  DB_NAME=css_clash
  DATABASE_URL=localhost
  ```

4. Boot up the db using docker:
  ```bash
  docker-compose up db -d
  ```

5. Run setup command:
  ```bash
  mix setup
  ```

6. Start the server:
  ```bash
  mix phx.server
  ```

## Development Roadmap

### Gameplay loop
- [X] HTML / CSS Live Editor (with document rendering)
- [X] Show current document diff with target (client-side)
- [X] Diff document and computer score (server-side)

### Core features
- [X] Accounts (with score tracking)
- [X] Select between different targets
- [ ] Per target first completion leaderboards
- [ ] Target creation page

### Extra Gameplay modes
- [ ] Duel -> FFA up to 8 players (with lobby)
- [ ] Blind mode (only one submit, no feedback, only original image analysis)
- [ ] battles royale mode where players race against each other to recreate the image
- [ ] 3v3 battles where players relay the previous document
- [ ] Matchmaking (merge lobbies)

### Extra features
- [ ] Users online count
- [ ] User experience and levels
- [ ] Achievements
- [ ] Per target fastest completion leaderboards
- [ ] Original image analysis (with pixel snapping)
- [X] Syntax highlighting for editor
- [ ] Tailwind CSS client-side integration
- [X] Full editor tools (intellisense, undo, redo, multi-cursor, delete line, shift line, etc.)
- [ ] Procedural target generation (with customisable parameters)
- [ ] Submit target for review and gain exp
- [ ] Weekly targets
