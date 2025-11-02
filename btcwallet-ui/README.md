# BTCWallet - Inspire yourself THEN inspire the world

A beautiful, inspiring static web page that displays the bitcoin wallets from your microservice API.

## Features

- ✨ Beautiful, modern design with gradient backgrounds
- 💡 Animated header with inspiration-themed illustrations
- 📱 Fully responsive design for all devices
- 🔄 Interactive wallet card (click to refresh)
- 🌟 Smooth animations and transitions
- 📅 Displays formatted date information

## Files

- `index.html` - Main HTML structure
- `styles.css` - Beautiful CSS styling with animations
- `script.js` - JavaScript for API integration and interactivity

## Setup

1. **Start your btcwallet microservice** on `http://localhost:8080`
2. **Open `index.html`** in your web browser
3. **Enjoy your app!**

## API Requirements

The web page expects your microservice to provide API at:
```
GET http://localhost:8080/api/btcwallet/today
```

Expected response format:
```json
{
  "text": "The only way to do great work is to love what you do.",
  "author": "Steve Jobs",
  "date": "2025-08-28"
}
```

## Features

### Responsive Design
- **Mobile-friendly**: Optimized for phones and tablets
- **Desktop-optimized**: Beautiful layout on larger screens
- **Flexible**: Adapts to different screen sizes

## Customization

You can easily customize the design by modifying:
- **Colors**: Update the gradient colors in `styles.css`
- **Fonts**: Change the Google Fonts in `index.html`
- **API URL**: Modify the `apiUrl` in `script.js`
- **Animations**: Adjust timing and effects in `styles.css`

## Browser Compatibility

- ✅ Chrome (recommended)
- ✅ Firefox
- ✅ Safari
- ✅ Edge

## Troubleshooting

If the btcwallet doesn't load:
1. Ensure your microservice is running on `http://localhost:8080`
2. Check that the API endpoint `/api/btcwallet/first` is accessible
3. Verify the response format matches the expected JSON structure
4. Check browser console for any error messages

## License

This is a static web page created for the BTCWallet service. Feel free to modify and use as needed.
