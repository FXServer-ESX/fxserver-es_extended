$('.container').hide();
window.addEventListener('message', function (event) {
  let eventData = event.data;

  if (eventData.method === 'open') {
    console.log(eventData.playerName);
    $('#player-name').html(`Welcome, ${eventData.playerName}`);
    $('#player-balance').html(`Balance: ${eventData.balance}`);
    $('.container').show();
  }

  else if (eventData.method === 'close') {
    $('.container').hide();
  }

  // more checks will be done
  else if (eventData.method === 'setMessage') {
    if (eventData.type === 'deposit') {
      switch (eventData.variant) {
        case 'success':
          $('#action-feedback').html('Your deposit was successful').fadeIn(1000)
          $('#action-feedback').fadeOut(2000)
          $('#player-balance').html(`Balance: ${eventData.newBalance}`);
          break;
        case 'error':
          $('#action-feedback').html('Your deposit failed. Maybe you are poor?').fadeIn(50)
          $('#action-feedback').fadeOut(2000)
          break;
      }
    } else if (eventData.type === 'withdraw') {
      switch (eventData.variant) {
        case 'success':
          $('#action-feedback').html('Your withdraw was successful').fadeIn(1000)
          $('#action-feedback').fadeOut(2000)
          $('#player-balance').html(`Balance: ${eventData.newBalance}`);
          break;
        case 'error':
          $('#action-feedback').html('Your withdraw failed. Maybe you are poor?').fadeIn(1000)
          $('#action-feedback').fadeOut(2000)
          break;
      }
    } else if (eventData.type === 'transfer') {
      switch (eventData.variant) {
        case 'success':
          $('#action-feedback').html('Your transfer was successful').fadeIn(1000)
          $('#action-feedback').fadeOut(2000)
          $('#player-balance').html(`Balance: ${eventData.newBalance}`);
          break;
        case 'error':
          $('#action-feedback').html('Your transfer failed. Maybe you are poor?').fadeIn(1000)
          $('#action-feedback').fadeOut(2000)
          break;
      }
    }
  }
});

const depositMoney = () => {
  const inputAmount = $('#input-amount').val();
  window.parent.postMessage({ action: 'atm.deposit', data: { targetAccount: 'fleeca', amount: inputAmount } }, '*');
}

const withdrawMoney = () => {
  const inputAmount = $('#input-amount').val();
  window.parent.postMessage({ action: 'atm.withdraw', data: { sourceAccount: 'fleeca', amount: inputAmount } }, '*');
}


let transferAmount;

const transferMoney = () => {
  // should send both the ID and the amount
  const amount = $('#input-amount').val();
  $('.transfer-modal').css('visibility', 'visible')
  transferAmount = amount
}

const confirmTransfer = () => {
  const playerId = $('#playerid').val()
  window.parent.postMessage({ action: 'atm.transfer', data: { sourceAccount: 'fleeca', targetAccount: 'fleeca', targetId: playerId, amount: transferAmount } }, '*');
  $('.transfer-modal').css('visibility', 'hidden')
}

const cancelTransfer = () => {
  $('.transfer-modal').css('visibility', 'hidden')
}

document.onkeyup = (data) => {
  if (data.which === 27) {
    // will close the atm when ESC is pressed
    $('.container').hide();
    window.parent.postMessage({ action: 'atm.close' }, '*');

  }
}
