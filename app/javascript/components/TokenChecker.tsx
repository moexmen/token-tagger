import React, { useState, useEffect } from 'react';
import QrReader from 'modern-react-qr-reader';

import Modal from './Modal';

export enum Result {
  Found = 'found',
  NoMatch = 'no-match',
  Error = 'error'
}

interface Student {
  id: number;
  school_code: string;
  school_name: string;
  serial_no: number;
  name: string;
  class_name: string;
  level: string;
  batch: string;
}

export interface StudentResult {
  result: Result;
  student: Student | null;
}

interface StudentModalProps {
  showModal: boolean;
  result: StudentResult | null;
  setShowModal: (show: boolean) => void;
}

const StudentModal = ({ result, showModal, setShowModal }: StudentModalProps ) => {
  if (!showModal) {
    return null;
  }

  if (result == null) {
    return (
      <Modal isOpen={showModal} parent={document.body}>
        <div className="modal-body">Checking token...</div>
      </Modal>
    );
  }

  useEffect(() => {
    if (buttonRef.current) {
      buttonRef.current.focus();
    }
  }, [result])

  const buttonRef = React.useRef(null);

  const student = result.student;
  let body = null;
  if (student != null) {
    body = (
      <div className="student-details">
        <div className="serial-no">{student.serial_no}</div>
        <div className="student">
          <div className="school">{student.school_name}</div>
          <div className="class">{student.class_name}</div>
          <div className="name">{student.name}</div>
        </div>
      </div>
    );
  }else if (result.result == Result.NoMatch) {
    body = (
      <>
        <h3>No student found</h3>
        <div>Seems like this token has not been assigned.</div>
      </>
    ); 
  } else {
    body = (
      <>
        <h3>Something went wrong</h3>
        <div>Please try again.</div>
      </>
    );
  }

  const closeModal = () => setShowModal(false);

  return (
    <Modal isOpen={showModal} parent={document.body} onBackdropClick={closeModal}>
      <div className="modal-body">
        {body}
      </div>
      <div className="modal-footer">
        <button ref={buttonRef} onClick={closeModal}>OK</button>
      </div>
    </Modal>
  );
}

interface TokenCheckerProps {
  isFetching: boolean;
  result: StudentResult | null;
  getStudentWithToken: (tokenId: string) => void;
}

export default (props: TokenCheckerProps) => {
  const { isFetching, result, getStudentWithToken } = props;

  const [tokenId, setTokenId] = useState('');
  const [showQr, setShowQr] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const tokenInputRef = React.useRef(null);

  useEffect(() => {
    if (!showModal) {
      setTokenId('');
      tokenInputRef.current.focus();
    }
  }, [showModal])

  useEffect(() => {
    // Show modal with result if result is available
    setShowModal(result != null || isFetching);
  }, [result, isFetching])

  const handleEnter = e => {
    if (tokenId === '' || showModal) {
      return;
    }
    
    if (e.charCode !== 13) {
      return;
    }
    getStudentWithToken(tokenId);
  }

  return (
    <div className="content">
      <StudentModal result={result} showModal={showModal} setShowModal={setShowModal} />

      <h3>Scan a token to get the tagged student</h3>
      <div className="token">
        <label htmlFor="tag">Token:</label>
        <input id="tag" autoFocus={true} type="text" ref={tokenInputRef} onChange={e => setTokenId(e.target.value)} value={tokenId} onKeyPress={handleEnter} />
      </div>

      {!showQr && <button className="camera" onClick={() => setShowQr(true)}>Use camera</button>}
      {showQr && <QrReader
        delay={100}
        onScan={data => {
          if (showModal) {
            return;
          }

          if (data) {
            setTokenId(data);
            getStudentWithToken(data);
          }
        }}
      />}
    </div>
  );
}
