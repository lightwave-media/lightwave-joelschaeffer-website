#!/bin/bash

# Initialize Git Repository for joelschaeffer.com
# LightWave Media - Git Convention Setup

cd "$(dirname "$0")"

echo "Initializing git repository..."
git init

echo "Creating main branch..."
git branch -M main

echo "Adding all files..."
git add .

echo "Creating baseline commit..."
git commit -m "$(cat <<'EOF'
chore(init): baseline e-commerce template for joelschaeffer.com

Initialize lightwave-joelschaeffer-website repository with Payload CMS e-commerce template.
This serves as the foundation for dual cinematography/photography portfolio with shop.

Template includes:
- Payload CMS 3.x + Next.js 15
- E-commerce collections (Products, Carts, Orders)
- Categories and Pages collections
- Media management
- Stripe integration

Next steps: Add dual portfolio collections (Artworks), configure for cinematography + photography.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "Creating develop branch..."
git branch develop

echo "Creating feature branch..."
git checkout -b feature/portfolio/task-001-dual-portfolio-setup

echo ""
echo "✅ Git initialized successfully!"
echo ""
echo "Branch structure:"
git branch -a

echo ""
echo "Current branch:"
git branch --show-current

echo ""
echo "Ready to start development!"
