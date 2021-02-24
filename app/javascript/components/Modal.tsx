import React, { Component } from 'react';
import * as ReactDOM from 'react-dom';

interface ModalProps {
  parent: Element;
  isOpen: boolean;
  onBackdropClick?: () => void;
}

export default class Modal extends Component<ModalProps> {
  static defaultProps = { onBackdropClick: () => { /* noop */ } };

  render() {
    return ReactDOM.createPortal(this.renderBody(), this.props.parent);
  }

  renderBody() {
    if (!this.props.isOpen) {
      return null;
    }

    return (
      <div className="modal">
        <div className="backdrop" onClick={this.props.onBackdropClick} />
        <div className="modal-dialog">
          {this.props.children}
        </div>
      </div>
    );
  }
}
