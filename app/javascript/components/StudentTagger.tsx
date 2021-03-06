import React, { useState, useEffect } from 'react';
import QrReader from 'modern-react-qr-reader';

import Modal from './Modal';

export enum FailureReasons {
  ApiError = 'api_error',
  InvalidToken = 'invalid_token',
  InvalidNric = 'invalid_nric',
  TokenAlreadyAssigned = 'token_already_assigned',
  PersonHasToken = 'person_has_token'
}

export interface Student {
  id: number;
  school_code: string;
  school_name: string;
  serial_no: number;
  name: string;
  class_name: string;
  level: string;
  batch: string;
}

export interface Result {
  success: boolean;
  reason: string;
  student: Student;
}

interface StudentTaggerProps {
  isFetching: boolean;
  result?: {
    success: boolean;
    reason: string;
    student: Student;
  };
  student: Student | null;
  assignToken: (tokenId: string, studentId: number) => void;
}

const FlashMessage = ({ result }: { result?: Result} ) => {
  if (result == null) {
    return null;
  }

  let cssClass = result.success ? 'banner success' : 'banner failure';
  if (result.reason == FailureReasons.PersonHasToken || result.reason == FailureReasons.InvalidNric) {
    cssClass = 'banner warning';
  }

  const student = <span><b>{result.student.serial_no}</b>{` | ${result.student.level} ${result.student.class_name} | ${result.student.name}`}</span>;
  if (result.success) {
    return (
      <div className={cssClass}>
        <h1>Success</h1>
        <p>{student} has been tagged to the token.</p>
        <p>Please label the token for this student.</p>
      </div>
    );
  } else if (result.reason == FailureReasons.PersonHasToken) {
    return (
      <div className={cssClass}>
        <h1>Student Error</h1>
        <p>{student} already has a token.</p>
        <p>Please assign this token to another student</p>
      </div>
    );
  } else if (result.reason == FailureReasons.InvalidNric) {
    // For completeness. Should not happen if we validate the nric while seeding our DB
    return (
      <div className={cssClass}>
        <h1>Student Error</h1>
        <p>{student}'s NRIC is invalid.</p>
        <p>Please assign this token to another student</p>
      </div>
    );
  } else if (result.reason == FailureReasons.TokenAlreadyAssigned) {
    return (
      <div className={cssClass}>
        <h1>Token Error</h1>
        <p>The token has already been tagged to someone else.</p>
        <p>Please scan with another token.</p>
      </div>
    );
  } else if (result.reason == FailureReasons.InvalidToken) {
    return (
      <div className={cssClass}>
        <h1>Input Error</h1>
        <p>Invalid Token ID</p>
        <p>Please try again or try to scan with another token.</p>
      </div>
    );
  } else {
    return (
      <div className={cssClass}>
        <h1>Error</h1>
        <p>Reason: {result.reason}</p>
        <p>Something went wrong! Please try again or try to scan with another token.</p>
      </div>
    );
  }
}

interface ResultModalProps {
  isFetching: boolean;
  showModal: boolean;
  result?: Result;
  isClassEnd?: boolean;
  setShowModal: (show: boolean) => void;
}
const ResultModal = ({ result, showModal, isFetching, setShowModal, isClassEnd = false }: ResultModalProps ) => {
  if (!showModal) {
    return null;
  }

  if (isFetching) {
    return (
      <Modal isOpen={showModal} parent={document.body}>
        <div className="modal-body">Tagging student...</div>
      </Modal>
    );
  }

  useEffect(() => {
    if (buttonRef.current) {
      buttonRef.current.focus();
    }
  }, [result])

  const buttonRef = React.useRef(null);
  const currClass = result?.student?.class_name || '';
  return (
    <Modal isOpen={showModal} parent={document.body}>
      <FlashMessage result={result} />
      {(isClassEnd && currClass !== '') && <div className="class-end-banner">Last student in {currClass}</div>}
      <div className="modal-footer">
        <button ref={buttonRef} onClick={() => setShowModal(false)}>OK</button>
      </div>
    </Modal>
  );
}

export default (props: StudentTaggerProps) => {
  const { student, result, isFetching, assignToken } = props;

  const [tokenId, setTokenId] = useState('');
  const [showQr, setShowQr] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const tokenInputRef = React.useRef(null);

  useEffect(() => {
    if (!showModal && tokenInputRef.current) {
      // Clear tokenId and set focus on token input field if modal is closed
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

    assignToken(tokenId, student.id);
  }

  if (student == null) {
    return (
      <div className="content">
        <ResultModal isFetching={isFetching} isClassEnd={true} result={result} showModal={showModal} setShowModal={setShowModal} />
        <div>Finshed tagging all students in this batch</div>
      </div>
    );
  }

  const isNextClass = `${result?.student?.level} ${result?.student?.class_name}` != `${student.level} ${student.class_name}`;
  const classCss = `class${isNextClass ? ' bold' : ''}`
  return (
    <div className="content">
      <ResultModal isFetching={isFetching} isClassEnd={isNextClass} result={result} showModal={showModal} setShowModal={setShowModal} />
      <div className="student-details">
        <div className="serial-no">{student.serial_no}</div>
        <div className="student">
        <div className="school">{student.school_name}</div>
          <div className={classCss}>{student.level} {student.class_name}</div>
          <div className="name">{student.name}</div>
        </div>
      </div>
      <b>Scan a token to tag to this student.</b>
      <div className="token">
        <label htmlFor="tag">Token:</label>
        <input id="tag" autoFocus={true} type="text" onChange={e => setTokenId(e.target.value)} value={tokenId} onKeyPress={handleEnter} ref={tokenInputRef} />
      </div>

      {!showQr && <button className="camera" onClick={() => setShowQr(true)}>Use camera</button>}
      {showQr && <QrReader
        delay={300}
        onScan={data => {
          if (showModal) {
            return;
          }

          if (data) {
            setTokenId(data);
            assignToken(data, student.id);
          }
        }}
      />}
    </div>
  )
}
