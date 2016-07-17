import {Socket} from "phoenix"

class DockupUiSocket {
  constructor(){
    this.initializeSocket();
  }

  initializeSocket() {
    this.socket = new Socket("/socket", {
      logger: (kind, msg, data) => {
        console.log(`${kind}: ${msg}`, data)
      }
    })
    this.socket.connect()
  }

  getDeploymentsChannel() {
    let channel = this.socket.channel("deployments:all", {});
    channel.join()
      .receive("ok", resp => { console.log("Joined deployments:all channel", resp) })
      .receive("error", resp => { console.log("Unable to join deployments:all channel", resp) })
    return channel;
  }
}

window.DockupUiSocket = new DockupUiSocket();

export default DockupUiSocket;
