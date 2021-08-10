package interop

import "sync"

type bgRunner struct {
	runner interface {
		Run() error
	}
	initOnce sync.Once
	blocker  chan struct{}
	err      error
}

func (b *bgRunner) init() {
	b.initOnce.Do(func() { b.blocker = make(chan struct{}) })
}

// Start calls the receiver's Run command in a new goroutine. Wait will block and return its error when it finishes.
func (b *bgRunner) Start() {
	if b.runner == nil {
		panic("nothing to start")
	}
	b.init()
	go func() {
		b.err = b.runner.Run()
		close(b.blocker)
	}()
}

// Wait for the process to finish running in the background, returning its error.
func (b *bgRunner) Wait() error {
	b.init()
	<-b.blocker
	return b.err
}
