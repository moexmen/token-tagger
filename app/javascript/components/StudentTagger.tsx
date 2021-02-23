import React, { useState, useEffect } from 'react';
import QrReader from 'react-qr-reader'

export enum FailureReasons {
  ApiError = 'api_error',
  InvalidToken = 'invalid_token',
  TokenAlreadyAssigned = 'token_already_assigned',
  PersonHasToken = 'person_has_token'
}

export interface Student {
  id: number;
  school_code: string;
  school_name: string;
  serial_no: string;
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
  result?: {
    success: boolean;
    reason: string;
    student: Student;
  };
  student: Student;
  assignToken: (tokenId: string, studentId: number) => void;
}

const FlashMessage = ({ result }: { result?: Result} ) => {
  if (result == null) {
    return null;
  }

  let cssClass = result.success ? 'banner success' : 'banner failure';
  if (result.reason == FailureReasons.PersonHasToken) {
    cssClass = 'banner warning';
  }

  const student = `${result.student.serial_no} (${result.student.class_name}) ${result.student.name}`;
  if (result.success) {
    return (
      <div className={cssClass}>
        <h3>Success</h3>
        <p><span>{student}</span> has been tagged to the token.</p>
        <p>Please label the token for this student.</p>
      </div>
    );
  } else if (result.reason == FailureReasons.PersonHasToken) {
    return (
      <div className={cssClass}>
        <h3>Student error</h3>
        <p><span>{student}</span> already has a token.</p>
        <p>Please discard the label and assign this token to another student</p>
      </div>
    );
  } else {
    const message = result.reason == FailureReasons.InvalidToken ? 'Invalid token id!' : 'Something went wrong! Please try to scan the token again';
    return (
      <div className={cssClass}>
        <h3>Error</h3>
        <p>{message}</p>
        <p>Please try again or try to scan with another token.</p>
      </div>
    );
  }
}
export default (props: StudentTaggerProps) => {
  const { student, result, assignToken } = props;

  const [tokenId, setTokenId] = useState('');
  const [showQr, setShowQr] = useState(false);

  useEffect(() => {
    setTokenId('');
  }, [student.id])

  const handleEnter = e => {
    if (e.charCode === 13 && tokenId !== '') {
      assignToken(tokenId, student.id)
    }
  }

  return (
    <div className="content">
      <FlashMessage result={result} />
      
      <div className="student-details">
        <div className="serial-no">{student.serial_no}</div>
        <div className="student">
          <div className="name">{student.name}</div>
          <div className="class">{student.class_name}</div>
          <div className="school">{student.school_name}</div>
        </div>
      </div>
      <div>Scan a token to tag to this student.</div>
      <div className="token">
        <div>
          <label htmlFor="tag">Token:</label>
          <input id="tag" autoFocus={true} type="text" onChange={e => setTokenId(e.target.value)} value={tokenId} onKeyPress={handleEnter} />
        </div>
        <button disabled={tokenId === ''} onClick={() => assignToken(tokenId, student.id)}>Go</button>
      </div>

      {!showQr && <button onClick={() => setShowQr(true)}>Use camera</button>}
      {showQr && <QrReader
        delay={100}
        onScan={data => {
          if (data) {
            setTokenId(data);
          }
        }}
      />}
    </div>
  )
}
