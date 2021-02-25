import React, { useState, useEffect } from 'react';
import QrReader from 'react-qr-reader';
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
  serial_no: string;
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

  const student = result.student;
  let body = null;
  if (student != null) {
    body = (
      <div className="student-details">
        <div className="serial-no">{student.serial_no}</div>
        <div className="student">
          <div className="name">{student.name}</div>
          <div className="class">{student.class_name}</div>
          <div className="school">{student.school_name}</div>
        </div>
      </div>
    );
  }else if (result.result == Result.NoMatch) {
    body = (
      <>
        <h3>No student found</h3>
        <div>Seems like this token has not been assigned.</div>;
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

  return (
    <Modal isOpen={showModal} parent={document.body}>
      <div className="modal-body">
        {body}
      </div>
      <div className="modal-footer">
        <button  onClick={() => setShowModal(false)}>OK</button>
      </div>
    </Modal>
  );
}

interface TokenCheckerProps {
  result: StudentResult | null;
  getStudentWithToken: (tokenId: string) => void;
}

export default (props: TokenCheckerProps) => {
  const { result, getStudentWithToken } = props;

  const [tokenId, setTokenId] = useState('');
  const [showQr, setShowQr] = useState(false);
  const [showModal, setShowModal] = useState(false);

  useEffect(() => {
    setTokenId('');
    // Show modal with student if result is available
    setShowModal(result != null);
  }, [result])

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

      <div>Scan a token to get the tagged student</div>
      <div className="token">
        <div>
          <label htmlFor="tag">Token:</label>
          <input id="tag" autoFocus={true} type="text" onChange={e => setTokenId(e.target.value)} value={tokenId} onKeyPress={handleEnter} />
        </div>
      </div>

      {!showQr && <button onClick={() => setShowQr(true)}>Use camera</button>}
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
