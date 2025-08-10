# 🌐 GitHub Pages Manual Setup Guide

## URL: https://github.com/Franklin-Andres-Rodriguez/eur-usd-trading-platform/settings/pages

### Steps:

1. **Go to Repository Settings**
   - Navigate to your repository
   - Click "Settings" tab
   - Scroll to "Pages" in left sidebar

2. **Configure Source**
   - Source: Select "GitHub Actions"
   - ✅ This will use the workflow in `.github/workflows/ci.yml`
   - ❌ Don't select "Deploy from a branch" (that's the old method)

3. **Custom Domain (Optional)**
   - Leave empty for default GitHub Pages URL
   - Or add your custom domain if you have one

4. **Save Changes**
   - Click "Save"
   - Wait 5-10 minutes for deployment

### Result:
Your site will be available at:
🔗 https://franklin-andres-rodriguez.github.io/eur-usd-trading-platform

### How it Works:
- The GitHub Actions workflow (`.github/workflows/ci.yml`) builds and deploys
- Every push to `main` triggers automatic deployment
- No manual uploads needed
- Built-in SSL certificate
- Global CDN distribution

### Troubleshooting:
- If deployment fails, check Actions tab for errors
- Ensure `index.html` exists in repository root
- Verify workflow has Pages deployment permissions
